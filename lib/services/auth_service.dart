import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kavelypeli/models/user_model.dart';

import '../widgets/input_dialog.dart';

class AuthService {
  final BuildContext context;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late AuthCredential _authCredential;
  late final User _user;
  late final DocumentReference _userDocRef,
      _userItemsDocRef,
      _userSettingsDocRef,
      _userStatisticsDocRef,
      _userAchievementsDocRef;

  AuthService({required this.context}) {
    _user = FirebaseAuth.instance.currentUser!;
    _userDocRef = _db.collection("users").doc(_user.uid);
    _userItemsDocRef = _db.collection("user_items").doc(_user.uid);
    _userSettingsDocRef = _db.collection("user_settings").doc(_user.uid);
    _userStatisticsDocRef = _db.collection("user_statistics").doc(_user.uid);
    _userAchievementsDocRef = _db.collection("user_achievements").doc(_user.uid);
  }

  Future<String?> reAuthenticate() async {
    final reAuthPassword = await InputDialog.showInputDialog(
      context,
      const InputDialog(
        title: Text("Re-authenticate"),
        inputDecoration: InputDecoration(labelText: "Type your password"),
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        inputType: InputType.password,
      ),
    );
    return reAuthPassword;
  }

  Future<Map<String, dynamic>> deleteUser(String password) async {
    try {
      _authCredential =
          EmailAuthProvider.credential(email: _user.email!, password: password);
      await _user.reauthenticateWithCredential(_authCredential);
      await _userItemsDocRef.delete();
      await _userSettingsDocRef.delete();
      await _userStatisticsDocRef.delete();
      await _userAchievementsDocRef.delete();
      await _userDocRef.delete();
      await _user.delete();
      return {"result": true, "message": "User deleted."};
    } on FirebaseAuthException catch (e) {
      if (e.code == "wrong-password") {
        return {"result": false, "message": "Wrong password."};
      }
      return {"result": false, "message": "Account could not be deleted."};
    }
  }

  Future<Map<String, dynamic>> changeUsername(
      String reAuthPassword, String newUsername) async {
    try {
      _authCredential = EmailAuthProvider.credential(
          email: _user.email!, password: reAuthPassword);
      await _user.reauthenticateWithCredential(_authCredential);
      return {"result": true, "message": "Username changed."};
    } on FirebaseAuthException catch (e) {
      if (e.code == "wrong-password") {
        return {"result": false, "message": "Wrong password."};
      } else if (e.code == "username-too-short") {
        return {"result": false, "message": "Username too short."};
      }
      return {"result": false, "message": "Username could not be changed."};
    }
  }

  Future<Map<String, dynamic>> changeEmail(
      String reAuthPassword, String newEmail) async {
    try {
      _authCredential = EmailAuthProvider.credential(
          email: _user.email!, password: reAuthPassword);
      await _user.reauthenticateWithCredential(_authCredential);
      await _user.updateEmail(newEmail);
      return {"result": true, "message": "Email changed"};
    } on FirebaseAuthException catch (e) {
      if (e.code == "wrong-password") {
        return {"result": false, "message": "Wrong password."};
      } else if (e.code == "invalid-email") {
        return {"result": false, "message": "Invalid email."};
      }
      return {"result": false, "message": "Email could not be changed."};
    }
  }

  Future<Map<String, dynamic>> changePassword(
      String reAuthPassword, String newPassword) async {
    try {
      _authCredential = EmailAuthProvider.credential(
          email: _user.email!, password: reAuthPassword);
      await _user.reauthenticateWithCredential(_authCredential);
      await _user.updatePassword(newPassword);
      return {"result": true, "message": "Password changed."};
    } on FirebaseAuthException catch (e) {
      if (e.code == "wrong-password") {
        return {"result": false, "message": "Wrong password."};
      } else if (e.code == "password-too-short") {
        return {"result": false, "message": "Password too short."};
      }
      return {"result": false, "message": "Password could not be changed."};
    }
  }
}
