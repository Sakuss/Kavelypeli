import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kavelypeli/models/user_model.dart';
import 'dart:convert';

import 'package:kavelypeli/util.dart';

enum MoneyType {
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
  final _storage = FirebaseStorage.instance.ref("shop_item_pics");
  final _itemsCollRef = FirebaseFirestore.instance.collection("items");
  final _userItemsCollRef = FirebaseFirestore.instance.collection("user_items");
  final _userCollRef = FirebaseFirestore.instance.collection("users");
  List<Map<String, dynamic>>? _buyableItems = null;

  @override
  void initState() {
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
          _storage.child(item["shop_image"]).getDownloadURL().then((itemUrl) {
            item["itemUrl"] = itemUrl;
            allData.add(item);
            allData.add(item);
            allData.add(item);
          }).whenComplete(() => setState(() => _buyableItems = allData));
        }
      });
    } catch (_) {}
  }

  void _addItem(String itemName) {
    try {
      final userDocRef = _userCollRef.doc(widget.user.uid);

      _db.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDocRef);
        final String userItemsDocName = userSnapshot.get("itemDoc");
        print(userItemsDocName);
        final userItemDocRef = _userItemsCollRef.doc(userItemsDocName);
        final userItemsSnapshot = await transaction.get(userItemDocRef);
        List items = userItemsSnapshot.get("items");
        print(items);

        items.add(itemName);
        transaction.update(userItemDocRef, {"items": items});
      }).then((value) {
        print("_additem");
      }).onError((error, stackTrace) {
        print(error);
        print("_additem error");
      });
    } catch (_) {}
  }

  void _buyItem(
      final Map<String, dynamic> item, int amount, MoneyType currency) {
    try {
      final userDocRef = _userCollRef.doc(widget.user.uid);
      _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);

        if (currency == MoneyType.realMoney) {
          final int balance = snapshot.get("currency");
          final int newBalance = balance - amount;

          if (newBalance < 0) {
            throw {"error": "insufficient-balance", "balance": balance};
          } else {
            transaction.update(userDocRef, {"currency": newBalance});
          }
        } else if (currency == MoneyType.points) {
          final balance = snapshot.get("points");
          final newBalance = balance - amount;

          if (newBalance < 0) {
            throw {"error": "insufficient-balance", "balance": balance};
          } else {
            transaction.update(userDocRef, {"points": newBalance});
          }
        }
      }).then(
        (_) {
          if (currency == MoneyType.realMoney) {
            Util().showSnackBar(
                context, "You bought ${item["name"]} for $amount €");
          } else if (currency == MoneyType.points) {
            Util().showSnackBar(
                context, "You bought ${item["name"]} for $amount points");
          }
          _addItem(item["character_image"]);
          print("UserDocument successfully updated!");
        },
        onError: (e) {
          final diff = amount - e["balance"] as int;

          if (currency == MoneyType.realMoney) {
            Util().showSnackBar(
                context, "Insufficient balance, you need $diff € more");
          } else if (currency == MoneyType.points) {
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
    return _buyableItems == null
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
                    ..._buyableItems!.map(
                      (item) {
                        return item["itemUrl"] == null
                            ? _placeholderItem
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                  image: DecorationImage(
                                      image: NetworkImage(item["itemUrl"]),
                                      fit: BoxFit.cover),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () => _buyItem(
                                        item,
                                        item["ingame_currency_price"] as int,
                                        MoneyType.points,
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
                                      ),
                                      child: Text(
                                          "${item["ingame_currency_price"]} @"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _buyItem(
                                        item,
                                        item["money_price"] as int,
                                        MoneyType.realMoney,
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
                                      ),
                                      child: Text("${item["money_price"]} €"),
                                    ),
                                  ],
                                ),
                              );
                      },
                    )
                  ],
                  // children: [
                  //   for (int i = 0; i < 10; i++)
                  //     Container(
                  //       decoration: BoxDecoration(
                  //           image: DecorationImage(
                  //               image: NetworkImage(
                  //                   "https://picsum.photos/250?image=$i"),
                  //               fit: BoxFit.cover)),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         crossAxisAlignment: CrossAxisAlignment.end,
                  //         children: <Widget>[
                  //           ElevatedButton(
                  //             onPressed: buyItem,
                  //             style: ButtonStyle(
                  //               shape: MaterialStateProperty.all<
                  //                   RoundedRectangleBorder>(
                  //                 const RoundedRectangleBorder(
                  //                   borderRadius: BorderRadius.only(
                  //                       topLeft: Radius.circular(15.0),
                  //                       bottomLeft: Radius.circular(15.0)),
                  //                 ),
                  //               ),
                  //             ),
                  //             child: const Text("100 @"),
                  //           ),
                  //           ElevatedButton(
                  //             onPressed: buyItem,
                  //             style: ButtonStyle(
                  //               shape: MaterialStateProperty.all<
                  //                   RoundedRectangleBorder>(
                  //                 const RoundedRectangleBorder(
                  //                   borderRadius: BorderRadius.only(
                  //                       topRight: Radius.circular(15.0),
                  //                       bottomRight: Radius.circular(15.0)),
                  //                 ),
                  //               ),
                  //             ),
                  //             child: const Text("1 €"),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  // ],
                ),
              ),
            ],
          );
  }
}
