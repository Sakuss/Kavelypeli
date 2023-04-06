import 'dart:ui';

enum ItemType { hat, glasses, shirt, jacket, pants, gloves, shoes }

class AppItem {
  final String name;
  final String? description;
  final int buyPrice;
  final Image image;
  final ItemType type;

  AppItem({
    required this.name,
    required this.image,
    required this.type,
    required this.buyPrice,
    this.description,
  });

  factory AppItem.fromJson(Map<String, dynamic> parsedJson) {
    return AppItem(
      name: parsedJson["name"] ?? "",
      image: parsedJson["image"] ?? "",
      type: parsedJson["type"] ?? "",
      buyPrice: parsedJson["buyPrice"] ?? "",
      description: parsedJson["description"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "image": image,
      "type": type,
      "buyPrice": buyPrice,
      "description": description,
    };
  }
}
