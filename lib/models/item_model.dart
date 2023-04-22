import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum CategoryType { all, hats, glasses, shirts, pants, gloves, shoes }

class AppItem {
  late final String? shopImageUrl, characterImageUrl;
  late bool equipped;
  final String name, shopImage, characterImage;
  final int moneyPrice, currencyPrice;
  final CategoryType? category;

  // final String? description;
  // final ItemType type;

  AppItem({
    required this.shopImageUrl,
    required this.characterImageUrl,
    required this.equipped,
    required this.name,
    required this.shopImage,
    required this.characterImage,
    required this.moneyPrice,
    required this.currencyPrice,
    required this.category,
  });

  static Future<AppItem> createItem(Map<String, dynamic> item) async {
    var storageShopBucketRef = FirebaseStorage.instance.ref("shop_item_pics");
    var storageCharacterBucketRef =
        FirebaseStorage.instance.ref("character_item_pics");

    final shopUrl =
        await storageShopBucketRef.child(item["shop_image"]).getDownloadURL();
    final characterUrl = await storageCharacterBucketRef
        .child(item["character_image"])
        .getDownloadURL();

    return AppItem(
      name: item["name"],
      shopImage: item["shop_image"],
      characterImage: item["character_image"],
      moneyPrice: item["money_price"],
      currencyPrice: item["currency_price"],
      shopImageUrl: shopUrl,
      characterImageUrl: characterUrl,
      equipped: item["equipped"] ?? false,
      category: getCategoryType(item["category"]),
    );
  }

  static CategoryType getCategoryType(String value) {
    switch (value) {
      case "hats":
        return CategoryType.hats;
      case "glasses":
        return CategoryType.glasses;
      case "shirts":
        return CategoryType.shirts;
      case "pants":
        return CategoryType.pants;
      case "gloves":
        return CategoryType.gloves;
      case "shoes":
        return CategoryType.shoes;
      default:
        return CategoryType.all;
    }
  }

  static String? getCategoryTypeString(CategoryType value) {
    switch (value) {
      case CategoryType.hats:
        return "hats";
      case CategoryType.glasses:
        return "glasses";
      case CategoryType.shirts:
        return "shirts";
      case CategoryType.pants:
        return "pants";
      case CategoryType.gloves:
        return "gloves";
      case CategoryType.shoes:
        return "shoes";
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "shop_image": shopImage,
      "character_image": characterImage,
      "money_price": moneyPrice,
      "currency_price": currencyPrice,
      "equipped": equipped,
      "category": getCategoryTypeString(category!),
    };
  }
}
