import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kavelypeli/models/item_model.dart';
import 'package:kavelypeli/models/user_model.dart';
import 'dart:convert';

import 'package:kavelypeli/util.dart';

enum PurchaseType {
  realMoney,
  points,
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

  // final _storage = FirebaseStorage.instance.ref("shop_item_pics");
  final _itemsCollRef = FirebaseFirestore.instance.collection("items");
  final _userItemsCollRef = FirebaseFirestore.instance.collection("user_items");
  final _userCollRef = FirebaseFirestore.instance.collection("users");

  // List<Map<String, dynamic>>? _buyableItems = null;
  List<AppItem> _buyableItems = [];

  // List<AppItem> _userItems = [];
  bool _storeLoaded = false;

  @override
  void initState() {
    // print("SHOP INITSTATE");
    super.initState();
    _initPlatformState();
  }

  void _initPlatformState() {
    _getData();
    // widget.user.getUserItems().then((value) {
    //   setState(() {
    //     _userItems = value;
    //   });
    // });
  }

  void _getData() {
    try {
      _itemsCollRef.get().then((querySnapshot) {
        final List<Map<String, dynamic>> allData =
            querySnapshot.docs.map((doc) => doc.data()).toList();

        for (final item in allData) {
          if (!mounted) return;
          // AppItem.createShopItem(item).then((value) {
          AppItem.createItem(item).then((value) {
            setState(() {
              _buyableItems.add(value);
              _buyableItems
                  .sort((a, b) => a.moneyPrice.compareTo(b.moneyPrice));
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

  // void _updateUserItems(AppItem appItem) {
  //   try {
  //     widget.user.getUserItems().then((itemList) {
  //       _db.runTransaction((transaction) async {
  //         final userItemDocRef = _userItemsCollRef.doc(widget.user.uid);
  //         itemList.add(appItem);
  //         List<Map<String, dynamic>> json =
  //             itemList.map((item) => item.toJson()).toList();
  //         transaction.update(userItemDocRef, {"items": json});
  //       }).whenComplete(() {
  //         print("User items updated");
  //       }).onError((error, stackTrace) {
  //         print(error);
  //         print("_updateUserItems error");
  //       });
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  void _updateUserItems(AppItem appItem) {
    try {
      _db.runTransaction((transaction) async {
        final userItemDocRef = _userItemsCollRef.doc(widget.user.uid);
        widget.user.userItems!.add(appItem);
        List<Map<String, dynamic>> json =
            widget.user.userItems!.map((item) => item.toJson()).toList();
        transaction.update(userItemDocRef, {"items": json});
      }).whenComplete(() {
        print("User items updated");
      }).onError((error, stackTrace) {
        print(error);
        print("_updateUserItems error");
      });
    } catch (e) {
      print(e);
    }
  }

  bool _doesAlreadyOwn(AppItem item) {
    // for (AppItem i in _userItems) {
    for (AppItem i in widget.user.userItems!) {
      if (item.name == i.name) {
        return true;
      }
    }
    return false;
  }

  void _buyItem(AppItem item, PurchaseType currency) {
    try {
      if (_doesAlreadyOwn(item)) return;

      final userDocRef = _userCollRef.doc(widget.user.uid);
      _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);

        if (currency == PurchaseType.realMoney) {
          final int balance = snapshot.get("currency");
          final int newBalance = balance - item.moneyPrice;

          if (newBalance < 0) {
            throw {"error": "insufficient-balance", "balance": balance};
          } else {
            transaction.update(userDocRef, {"currency": newBalance});
            widget.user.currency = newBalance;
            setState(() {
              widget.user.userItems!.add(item);
            });
          }
        } else if (currency == PurchaseType.points) {
          final int balance = snapshot.get("points");
          final int newBalance = balance - item.pointsPrice;

          if (newBalance < 0) {
            throw {"error": "insufficient-balance", "balance": balance};
          } else {
            transaction.update(userDocRef, {"points": newBalance});
            widget.user.points = newBalance;
            setState(() {
              widget.user.userItems!.add(item);
            });
          }
        }
      }).then(
        (_) {
          if (currency == PurchaseType.realMoney) {
            Util().showSnackBar(
                context, "You bought ${item.name} for ${item.moneyPrice} €");
          } else if (currency == PurchaseType.points) {
            Util().showSnackBar(context,
                "You bought ${item.name} for ${item.pointsPrice} points");
          }
          _updateUserItems(item);
          print("UserDocument successfully updated!");
        },
        onError: (e) {
          final diff = currency == PurchaseType.realMoney
              ? item.moneyPrice - e["balance"] as int
              : item.pointsPrice - e["balance"] as int;

          if (currency == PurchaseType.realMoney) {
            Util().showSnackBar(
                context, "Insufficient balance, you need $diff € more");
          } else if (currency == PurchaseType.points) {
            Util().showSnackBar(
                context, "Insufficient balance, you need $diff @ more");
          }
          print("Error updating document $e");
        },
      );
    } catch (_) {
      Util().showSnackBar(context, "Could not buy item.");
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
        : CustomScrollView(
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
                                      // image: NetworkImage(item["itemUrl"]),
                                      image: NetworkImage(item.shopImageUrl!),
                                      fit: BoxFit.cover),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: _doesAlreadyOwn(item)
                                          ? null
                                          : () => _buyItem(
                                                item,
                                                PurchaseType.points,
                                              ),
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15.0),
                                                bottomLeft:
                                                    Radius.circular(15.0)),
                                          ),
                                        ),
                                        backgroundColor: _doesAlreadyOwn(item)
                                            ? MaterialStateProperty.all(
                                                Colors.grey)
                                            : null,
                                      ),
                                      child: Text("${item.pointsPrice} @"),
                                    ),
                                    ElevatedButton(
                                      onPressed: _doesAlreadyOwn(item)
                                          ? null
                                          : () => _buyItem(
                                                item,
                                                PurchaseType.realMoney,
                                              ),
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(15.0),
                                                bottomRight:
                                                    Radius.circular(15.0)),
                                          ),
                                        ),
                                        backgroundColor: _doesAlreadyOwn(item)
                                            ? MaterialStateProperty.all(
                                                Colors.grey)
                                            : null,
                                      ),
                                      // child: Text("${item["money_price"]} €"),
                                      child: Text("${item.moneyPrice} €"),
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
          );
  }
}
