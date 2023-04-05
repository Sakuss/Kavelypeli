import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../util.dart';
import '../widgets/input_dialog.dart';

class AuthService {
  final BuildContext context;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late AuthCredential _authCredential;
  final User _firebaseUser = FirebaseAuth.instance.currentUser!;
  final Map<String, dynamic> updates = {
    "email": FieldValue.delete(),
    "username": FieldValue.delete(),
    "password": FieldValue.delete(),
    "ingame_currency": FieldValue.delete(),
  };

  AuthService({required this.context});

  String? get uid => _firebaseUser.uid;
  String? get username => _firebaseUser.displayName;
  String? get email => _firebaseUser.email;

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
      final docRefUser = _db.collection("users").doc(uid);
      _authCredential = EmailAuthProvider.credential(
          email: _firebaseUser.email!, password: password);
      await _firebaseUser.reauthenticateWithCredential(_authCredential);
      // docRefUser.update(updates);
      // docRefUser.delete().then((doc) {
      //   _firebaseUser.delete();
      // });
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
      if (newUsername.characters.length < 5) {
        throw FirebaseAuthException(code: "username-too-short");
      }
      _authCredential = EmailAuthProvider.credential(
          email: _firebaseUser.email!, password: reAuthPassword);
      await _firebaseUser.reauthenticateWithCredential(_authCredential);
      final docRefUser = _db.collection("users").doc(uid);
      // docRefUser.update({"username": newUsername});
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
    // final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    try {
      // if (!regex.hasMatch(newEmail)) {
      //   throw FirebaseAuthException(code: "invalid-email");
      // }
      final docRefUser = _db.collection("users").doc(uid);
      // docRefUser.update({"email": newEmail});
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
      String password, String newPassword) async {
    return {"result": false, "message": "TODO"};
  }
}
