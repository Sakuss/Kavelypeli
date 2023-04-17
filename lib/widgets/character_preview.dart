import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kavelypeli/models/item_model.dart';
import 'package:kavelypeli/models/user_model.dart';

class CharacterPreview extends StatefulWidget {
  final AppUser user;

  const CharacterPreview({Key? key, required this.user}) : super(key: key);

  @override
  State<CharacterPreview> createState() => _CharacterPreviewState();
}

class _CharacterPreviewState extends State<CharacterPreview> {
  final usersDocRef = FirebaseFirestore.instance.collection("users");
  final userItemsDocRef = FirebaseFirestore.instance.collection("user_items");
  final _storage = FirebaseStorage.instance.ref("character_item_pics");
  Image? _avatar = null;
  final Image _localDefaultAvatar =
      Image.asset("assets/images/default_avatar.png");
  bool _isAvatarLoaded = false;
  late List<AppItem> _userItems = [];

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  void _initPlatformState() {
    _getUserAvatar();
    _getUserAvatarItems();
  }

  void _getUserAvatarItems() {
    widget.user.getUserItems().then((value) {
      for (AppItem item in value) {
        _storage.child(item.characterImage).getDownloadURL().then((itemUrl) {
          item.itemUrl = itemUrl;
        }).whenComplete(() {
          setState(() {
            _userItems.add(item);
          });
          // print(_userItems);
        });
      }
    });
  }

  void _getUserAvatar() {
    try {
      usersDocRef.doc(widget.user.uid).get().then((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final avatarName = data["avatar"];
        if (avatarName == null) {
          setState(() {
            _isAvatarLoaded = true;
          });
        } else {
          _storage.child(avatarName).getDownloadURL().then(
            (avatarUrl) {
              setState(() {
                _avatar = Image.network(avatarUrl);
              });
            },
          ).whenComplete(() {
            setState(() {
              _isAvatarLoaded = true;
            });
          });
        }
      });
    } catch (e) {
      setState(() {
        _isAvatarLoaded = true;
      });
    }
  }

  Widget get _loadingAvatar {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: const CircularProgressIndicator(),
          ),
          const Text(
            "Loading avatar",
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  Widget get _loadingItems {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: const CircularProgressIndicator(),
          ),
          const Text(
            "Loading items",
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print("building character_preview");
    return !_isAvatarLoaded
        ? _loadingAvatar
        : Stack(
            children: [
              _avatar ?? _localDefaultAvatar,
              ..._userItems.map((item) => Image.network(item.itemUrl!)),
            ],
          );
  }
}
