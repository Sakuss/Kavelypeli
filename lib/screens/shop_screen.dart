import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ShopPage extends StatefulWidget {
  static const IconData icon = Icons.shopping_basket;
  static const String name = "Shop";

  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance.ref();
  final _itemsDocRef = FirebaseFirestore.instance.collection("items");
  List<Map<String, dynamic>>? _buyableItems = null;
  int i = 0;

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
      _itemsDocRef.get().then((querySnapshot) {
        var allData = querySnapshot.docs.map((doc) => doc.data()).toList();
        // setState(() {
        //   _buyableItems = querySnapshot.docs.map((doc) => doc.data()).toList();
        // });

        for (final item in allData) {
          _storage.child(item["thumbnail"]).getDownloadURL().then((itemUrl) {
            allData.add({"shopImage": NetworkImage(itemUrl)});
            i++;
            if (i == allData.length) {
              setState(() {
                _buyableItems = allData;
                // print(_buyableItems);
              });
            }
          });
        }

        // final data = doc.data() as Map<String, dynamic>;
        // print(data);
        // final avatarName = data["avatar"];
        // if (avatarName == null) {
        //   setState(() {
        //     _isAvatarLoaded = true;
        //   });
        // } else {

        // }
      });
    } catch (_) {}
  }

  void buyItem() {
    // nothing here yet
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
                    ..._buyableItems!.map((item) {
                      return Container(
                        decoration: BoxDecoration(
                            image: item["shopImage"] ??
                                DecorationImage(
                                    image: item["shopImage"],
                                    fit: BoxFit.cover)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: buyItem,
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15.0),
                                        bottomLeft: Radius.circular(15.0)),
                                  ),
                                ),
                              ),
                              child: const Text("100 @"),
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
                                  ),
                                ),
                              ),
                              child: const Text("1 €"),
                            ),
                          ],
                        ),
                      );
                    })
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
