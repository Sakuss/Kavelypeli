import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kavelypeli/models/item_model.dart';
import 'package:kavelypeli/models/user_model.dart';
import 'dart:convert';

import 'package:kavelypeli/util.dart';

enum PurchaseType {
  money,
  currency,
}

class ShopPage extends StatefulWidget {
  static const IconData icon = Icons.shopping_basket;
  static const String name = "Shop";
  final AppUser user;

  const ShopPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final _db = FirebaseFirestore.instance;
  final _itemsCollRef = FirebaseFirestore.instance.collection("items");
  final _userCollRef = FirebaseFirestore.instance.collection("users");

  List<AppItem> _buyableItems = [];
  List<AppItem> _buyableItemsCopy = [];

  bool _storeLoaded = false;

  static const List<String> filters = [
    "Name A-Z",
    "Name Z-A",
    "Money price lowest",
    "Money price highest",
    "Currency price lowest",
    "Currency price highest",
  ];
  static const List<String> categories = [
    "All",
    "Hats",
    "Glasses",
    "Shirts",
    "Pants",
    "Gloves",
    "Shoes",
  ];
  String filtersDropdownValue = filters.first;
  String categoriesDropdownValue = categories.first;

  @override
  void initState() {
    // print("SHOP INITSTATE");
    super.initState();
    _initPlatformState();
  }

  void _initPlatformState() {
    _getData();
  }

  void _getData() {
    try {
      _itemsCollRef.get().then((querySnapshot) {
        final List<Map<String, dynamic>> allData =
            querySnapshot.docs.map((doc) => doc.data()).toList();

        for (final item in allData) {
          if (!mounted) return;
          AppItem.createItem(item).then((value) {
            setState(() {
              _buyableItems.add(value);
              _filtersHandler("Name A-Z");
            });
          });
        }
      }).whenComplete(() {
        setState(() {
          _storeLoaded = true;
        });
      });
    } catch (_) {}
  }

  bool _doesAlreadyOwn(AppItem item) {
    for (AppItem i in widget.user.userItems!) {
      if (item.name == i.name) {
        return true;
      }
    }
    return false;
  }

  void _buyItem(AppItem item, PurchaseType purchaseType) {
    try {
      if (_doesAlreadyOwn(item)) return;
      print("buy");

      final userDocRef = _userCollRef.doc(widget.user.uid);
      _db.runTransaction((transaction) async {
        if (purchaseType == PurchaseType.currency) {
          final int balance = widget.user.currency!;
          final int newBalance = balance - item.currencyPrice;

          if (newBalance < 0) {
            throw {"error": "insufficient-balance", "balance": balance};
          } else {
            transaction.update(userDocRef, {"currency": newBalance});
            widget.user.currency = newBalance;
          }
        } else if (purchaseType == PurchaseType.money) {}
      }).then(
        (_) {
          if (purchaseType == PurchaseType.money) {
            Util().showSnackBar(
                context, "You bought ${item.name} for ${item.moneyPrice} €");
          } else if (purchaseType == PurchaseType.currency) {
            Util().showSnackBar(context,
                "You bought ${item.name} for ${item.currencyPrice} points");
          }
          setState(() {
            widget.user.userItems!.add(item);
            widget.user.saveItemsToDb();
          });
          print("UserDocument successfully updated!");
        },
        onError: (e) {
          final diff = item.currencyPrice - e["balance"] as int;

          Util().showSnackBar(
              context, "Insufficient balance, you need $diff @ more");

          print("Error updating document $e");
        },
      );
    } catch (_) {
      Util().showSnackBar(context, "Could not buy item.");
    }
  }

  void _categoriesHandler(CategoryType categoryType) {
    _buyableItemsCopy = _buyableItemsCopy.isEmpty
        ? List.from(_buyableItems)
        : _buyableItemsCopy;
    _buyableItems = List.from(_buyableItemsCopy);

    switch (categoryType) {
      case CategoryType.hats:
        _buyableItems
            .removeWhere((element) => element.category != CategoryType.hats);
        break;
      case CategoryType.glasses:
        _buyableItems
            .removeWhere((element) => element.category != CategoryType.glasses);
        break;
      case CategoryType.shirts:
        _buyableItems
            .removeWhere((element) => element.category != CategoryType.shirts);
        break;
      case CategoryType.pants:
        _buyableItems
            .removeWhere((element) => element.category != CategoryType.pants);
        break;
      case CategoryType.gloves:
        _buyableItems
            .removeWhere((element) => element.category != CategoryType.gloves);
        break;
      case CategoryType.shoes:
        _buyableItems
            .removeWhere((element) => element.category != CategoryType.shoes);
        break;
      case CategoryType.all:
        _buyableItems = List.from(_buyableItemsCopy);
        break;
    }
    _filtersHandler(filtersDropdownValue);
  }

  void _filtersHandler(String filterType) {
    switch (filterType) {
      case "Name A-Z":
        _buyableItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      case "Name Z-A":
        _buyableItems.sort((a, b) => b.name.compareTo(a.name));
        break;
      case "Money price lowest":
        _buyableItems.sort((a, b) {
          int priceComparison = a.moneyPrice.compareTo(b.moneyPrice);
          if (priceComparison != 0) {
            return priceComparison;
          }
          int nameComparison = a.name.compareTo(b.name);
          if (nameComparison != 0) {
            return nameComparison;
          }
          return a.name.compareTo(b.name);
        });
        break;
      case "Money price highest":
        _buyableItems.sort((a, b) {
          int priceComparison = b.moneyPrice.compareTo(a.moneyPrice);
          if (priceComparison != 0) {
            return priceComparison;
          }
          int nameComparison = a.name.compareTo(b.name);
          if (nameComparison != 0) {
            return nameComparison;
          }
          return a.name.compareTo(b.name);
        });
        break;
      case "Currency price lowest":
        _buyableItems.sort((a, b) {
          int priceComparison = a.currencyPrice.compareTo(b.currencyPrice);
          if (priceComparison != 0) {
            return priceComparison;
          }
          int nameComparison = a.name.compareTo(b.name);
          if (nameComparison != 0) {
            return nameComparison;
          }
          return a.name.compareTo(b.name);
        });
        break;
      case "Currency price highest":
        _buyableItems.sort((a, b) {
          int priceComparison = b.currencyPrice.compareTo(a.currencyPrice);
          if (priceComparison != 0) {
            return priceComparison;
          }
          int nameComparison = a.name.compareTo(b.name);
          if (nameComparison != 0) {
            return nameComparison;
          }
          return a.name.compareTo(b.name);
        });
        break;
    }
  }

  Widget get _loadingStore {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text("Loading store"),
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget get _placeholderItem {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return !_storeLoaded
        ? _loadingStore
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.5),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Currency",
                            style: TextStyle(fontSize: 25),
                          ),
                          Text(
                            "${widget.user.currency!}",
                            style: const TextStyle(fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 5.0,
                        ),
                        child: DropdownButton<String>(
                          // alignment: Alignment.center,
                          value: filtersDropdownValue,
                          // icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              filtersDropdownValue = value!;
                              _filtersHandler(value);
                            });
                          },
                          items: filters
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 5.0,
                        ),
                        child: DropdownButton<String>(
                          // alignment: Alignment.centerRight,
                          value: categoriesDropdownValue,
                          // icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              categoriesDropdownValue = value!;
                              _categoriesHandler(
                                  AppItem.getCategoryType(value.toLowerCase()));
                            });
                          },
                          items: categories
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverGrid.count(
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 2,
                        children: [
                          ..._buyableItems.map(
                            (item) {
                              return item.shopImageUrl == null
                                  ? _placeholderItem
                                  : Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                item.shopImageUrl!),
                                            fit: BoxFit.cover),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                ElevatedButton(
                                                  onPressed:
                                                      _doesAlreadyOwn(item)
                                                          ? null
                                                          : () => _buyItem(
                                                                item,
                                                                PurchaseType
                                                                    .currency,
                                                              ),
                                                  style: ButtonStyle(
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10.0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10.0)),
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        _doesAlreadyOwn(item)
                                                            ? MaterialStateProperty
                                                                .all(
                                                                    Colors.grey)
                                                            : null,
                                                  ),
                                                  child: Text(
                                                      "${item.currencyPrice} @"),
                                                ),
                                                ElevatedButton(
                                                  onPressed:
                                                      _doesAlreadyOwn(item)
                                                          ? null
                                                          : () => _buyItem(
                                                                item,
                                                                PurchaseType
                                                                    .money,
                                                              ),
                                                  style: ButtonStyle(
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        10.0),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10.0)),
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        _doesAlreadyOwn(item)
                                                            ? MaterialStateProperty
                                                                .all(
                                                                    Colors.grey)
                                                            : null,
                                                  ),
                                                  child: Text(
                                                      "${item.moneyPrice} €"),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
  }
}
