import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  void buyItem() {
    // nothing here yet
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
                  Container(
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://picsum.photos/250?image=1"),
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
                            ))),
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
                            ))),
                            child: const Text("1 €"),
                          ),
                        ]),
                  ),
                ],
              ))
        ]);
  }
}
