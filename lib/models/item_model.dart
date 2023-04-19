import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

// enum ItemType { hat, glasses, shirt, jacket, pants, gloves, shoes }


class AppItem {
  late String? shopImageUrl, characterImageUrl;
  final String name, shopImage, characterImage;
  final int moneyPrice, pointsPrice;

  // final String? description;
  // final ItemType type;

  AppItem({
    this.shopImageUrl,
    this.characterImageUrl,
    required this.name,
    required this.shopImage,
    required this.characterImage,
    required this.moneyPrice,
    required this.pointsPrice,
  });

  static Future<AppItem> createItem(Map<String, dynamic> item) async {
    // final token = await FirebaseAuth.instance.currentUser!.getIdToken();
    var storageShopBucketRef = FirebaseStorage.instance.ref("shop_item_pics");
    var storageCharacterBucketRef = FirebaseStorage.instance.ref("character_item_pics");

    final shopUrl = await storageShopBucketRef.child(item["shop_image"]).getDownloadURL();
    final characterUrl = await storageCharacterBucketRef.child(item["character_image"]).getDownloadURL();

    return AppItem(
      name: item["name"],
      shopImage: item["shop_image"],
      characterImage: item["character_image"],
      moneyPrice: item["money_price"],
      pointsPrice: item["points_price"],
      shopImageUrl: shopUrl,
      characterImageUrl: characterUrl,
    );
  }

  // static Future<AppItem?> createShopItem(Map<String, dynamic> item) async {
  //   try {
  //     final storage = FirebaseStorage.instance.ref("shop_item_pics");
  //     final url = await storage.child(item["shop_image"]).getDownloadURL();
  //     final AppItem appItem = createItem(item);
  //     appItem.shopImageUrl = url;
  //     return appItem;
  //   } catch (e) {
  //     print(e);
  //     return null;
  //   }
  // }
  //
  // static Future<AppItem?> createCharacterItem(Map<String, dynamic> item) async {
  //   try {
  //     final storage = FirebaseStorage.instance.ref("character_item_pics");
  //     final url = await storage.child(item["character_image"]).getDownloadURL();
  //     final AppItem appItem = createItem(item);
  //     appItem.characterImageUrl = url;
  //     return appItem;
  //   } catch (e) {
  //     print(e);
  //     return null;
  //   }
  // }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "shop_image": shopImage,
      "character_image": characterImage,
      "money_price": moneyPrice,
      "points_price": pointsPrice,
    };
  }
}
