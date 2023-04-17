import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_model.dart';
import '../widgets/profile.dart';

class ProfilePage extends StatefulWidget {
  final AppUser user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late AppUser user;
  final ImagePicker imagePicker = ImagePicker();
  final storageRef = FirebaseStorage.instance.ref();

  @override
  initState() {
    super.initState();
    user = widget.user;
  }

  void changeProfilePicture() async {
    final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    File file = File(image.path);
    var userImageRef = storageRef.child('profilepics/${user.uid}');
    try {
      await userImageRef.putFile(file);
      var photoURL = await AppUser.getPhotoURL(user.uid);
      setState(() {
        user.photoURL = photoURL;
      });
      print('Image uploaded successfully!');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Profile(
        user: user,
        changeProfilePicture: changeProfilePicture,
      ),
    );
  }
}
