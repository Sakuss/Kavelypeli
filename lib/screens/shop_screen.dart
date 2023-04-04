import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ShopPage extends StatefulWidget {
  static const IconData icon = Icons.shopping_basket;
  static const String name = "Shop";

  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class ItemClass {
  int _id;
  String image;
  int ingame_currency_price;
  int money_price;
  String name;

  ItemClass(this._id, this.image, this.ingame_currency_price, this.money_price,
      this.name);

  factory ItemClass.fromJson(dynamic json) {
    return ItemClass(
        json['_id'] as int,
        json['image'] as String,
        json['ingame_currency_price'] as int,
        json['money_price'] as int,
        json['name'] as String);
  }

  @override
  String toString() {
    return '{ ${this._id}, ${this.image}, ${this.ingame_currency_price}, ${this.money_price}, ${this.name} }';
  }
}

class _ShopPageState extends State<ShopPage> {
  final db = FirebaseFirestore.instance;

  Future<List> getItems() async {
    // Täällä pitäisi saada haettua: itemin nimi, kuva,
    // ingamecurrency hinta ja oikeerahahinta
    var itemId = 1;
    var items = [];

    db.collection("items").get().then(
      (querySnapshot) {
        print("Items fetched successfully");
        for (var docSnapshot in querySnapshot.docs) {
          items.add('${docSnapshot.id} => ${docSnapshot.data()}');
        }
        print(items);
      },
      onError: (e) => print("Error completing: $e"),
    );

    return items;
  }

  void buyItem() {
    // täällä pitäisi lisätä ostettu item käyttäjän
    // inventoryyn ja tarvittaessa poistaa ingame rahaa
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
        physics: const BouncingScrollPhysics(), // ?
        slivers: <Widget>[
          SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid.count(
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                children: <Widget>[
                  for (int i = 0;
                      i < 10; // tänne listan mitan verran toistoa (list.length) tai jtn
                      i++)
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(
                                  "https://picsum.photos/250?image=$i"), // tänne kuva oikealla indexillä i
                              fit: BoxFit.cover)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: getItems,
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    bottomLeft: Radius.circular(15.0)),
                              ))),
                              child: const Text("100 @"), // tänne pelirahahinta
                            ),
                            ElevatedButton(
                              onPressed: buyItem,
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15.0),
                                    bottomRight: Radius.circular(15.0)),
                              ))),
                              child: const Text("1 €"), // tänne oikearahahinta
                            ),
                          ]),
                    ),
                ],
              ))
        ]);
  }
}
