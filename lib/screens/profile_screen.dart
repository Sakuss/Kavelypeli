import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_model.dart';
import '../widgets/profile.dart';

class ProfilePage extends StatelessWidget {
  final AppUser user;
  final ImagePicker imagePicker = ImagePicker();
  final storageRef = FirebaseStorage.instance.ref();

  ProfilePage({super.key, required this.user});

  void changeProfilePicture() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Profile(
        uid: user.uid,
        photoURL: user.photoUrl,
        name: 'testname',
        title: 'Novice walker',
        changeProfilePicture: changeProfilePicture,
      ),
    );
  }
}
