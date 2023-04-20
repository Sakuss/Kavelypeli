import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kavelypeli/models/item_model.dart';
import 'dart:convert';

import 'package:kavelypeli/models/user_model.dart';

class InventoryPage extends StatefulWidget {
  final AppUser user;

  const InventoryPage({Key? key, required this.user}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final db = FirebaseFirestore.instance;

  void equipItem(AppItem appItem) {
    setState(() {
      appItem.equipped = !appItem.equipped;
      widget.user.saveItemsToDb();
    });
  }

  @override
  void initState() {
    super.initState();
    // print(widget.user.userItems!.map((e) => print("${e.name}, ${e.equipped}")));
  }

  @override
  Widget build(BuildContext context) {
    print(widget.user.userItems!.map((e) => print("${e.name}, ${e.equipped}")));
    return Scaffold(
        appBar: AppBar(title: const Text('Inventory')),
        body: CustomScrollView(
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
                        print(item.equipped);
                        return Card(
                          elevation: item.equipped ? 5 : 0,
                          shadowColor: item.equipped ? Colors.green : null,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(item.shopImageUrl!),
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
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : const Text("")),
                                ),
                                ElevatedButton(
                                  onPressed: () => equipItem(item),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              item.equipped
                                                  ? Colors.red
                                                  : Colors.green),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(7.0),
                                              ))),
                                  child: Text(
                                      item.equipped ? "Un-equip" : "Equip"),
                                ),
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
