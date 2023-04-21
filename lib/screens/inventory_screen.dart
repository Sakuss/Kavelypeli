import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kavelypeli/models/item_model.dart';

import 'package:kavelypeli/models/user_model.dart';

class InventoryPage extends StatefulWidget {
  final AppUser user;

  const InventoryPage({Key? key, required this.user}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  void _equipItem(AppItem appItem) {
    setState(() {
      appItem.equipped = !appItem.equipped;
      widget.user.saveItemsToDb();
    });
  }

  void _sellItem(AppItem appItem) {
    setState(() {
      widget.user.currency = widget.user.currency! + _getSellPrice(appItem);
      widget.user.userItems!.remove(appItem);
      widget.user.saveUserToDb();
      widget.user.saveItemsToDb();
    });
  }

  int _getSellPrice(AppItem appItem) {
    try {
      return (appItem.currencyPrice / 2).round();
    } catch (_) {
      return 0;
    }
  }

  Future<void> _showSellDialog(AppItem appItem) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sell ${appItem.name}"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    "Do you want to sell ${appItem.name} for ${_getSellPrice(appItem)} currency?"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Sell",
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _sellItem(appItem);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.user.userItems);
    return Scaffold(
        appBar: AppBar(title: const Text('Inventory')),
        body: widget.user.userItems!.isEmpty
            ? const Center(
                child: Text(
                  "You don't have any items yet ...",
                  style: TextStyle(fontSize: 22),
                ),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                    SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverGrid.count(
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          crossAxisCount: 2,
                          children: <Widget>[
                            ...widget.user.userItems!.map((item) {
                              return Card(
                                elevation: item.equipped ? 5 : 0,
                                shadowColor:
                                    item.equipped ? Colors.green : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image:
                                              NetworkImage(item.shopImageUrl!),
                                          fit: BoxFit.cover)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                            child: item.equipped
                                                ? const Text(
                                                    "Equipped",
                                                    style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                : const Text("")),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        // crossAxisAlignment:
                                        //     CrossAxisAlignment.end,
                                        children: <Widget>[
                                          ElevatedButton(
                                            onPressed: () => _equipItem(item),
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        item.equipped
                                                            ? Colors.red
                                                            : Colors.green),
                                                shape: MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10.0)),
                                                ))),
                                            child: Text(item.equipped
                                                ? "Un-equip"
                                                : "Equip"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _showSellDialog(item),
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.green),
                                                shape: MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10.0)),
                                                ))),
                                            child: const Text("Sell"),
                                          ),
                                        ],
                                      ),
                                      // ElevatedButton(
                                      //   onPressed: () => _equipItem(item),
                                      //   style: ButtonStyle(
                                      //       backgroundColor:
                                      //           MaterialStateProperty.all(
                                      //               item.equipped
                                      //                   ? Colors.red
                                      //                   : Colors.green),
                                      //       shape: MaterialStateProperty.all<
                                      //               RoundedRectangleBorder>(
                                      //           RoundedRectangleBorder(
                                      //         borderRadius:
                                      //             BorderRadius.circular(7.0),
                                      //       ))),
                                      //   child: Text(item.equipped
                                      //       ? "Un-equip"
                                      //       : "Equip"),
                                      // ),
                                      // ElevatedButton(
                                      //   onPressed: () => _sellItem(item),
                                      //   style: ButtonStyle(
                                      //       backgroundColor:
                                      //       MaterialStateProperty.all(
                                      //          Colors.green),
                                      //       shape: MaterialStateProperty.all<
                                      //           RoundedRectangleBorder>(
                                      //           RoundedRectangleBorder(
                                      //             borderRadius:
                                      //             BorderRadius.circular(7.0),
                                      //           ))),
                                      //   child: Text("Sell for ${_sellPrice(item)}"),
                                      // ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ))
                  ]));
  }
}
