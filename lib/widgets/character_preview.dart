import 'package:flutter/material.dart';
import 'package:kavelypeli/models/item_model.dart';

class CharacterPreview extends StatelessWidget {
  final List<AppItem> items;
  final Image? avatar;

  const CharacterPreview({required this.items, this.avatar, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        avatar ?? Image.asset("assets/images/default_avatar_light.png"),
      ],
    );
  }
}
