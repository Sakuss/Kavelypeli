import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/input_dialog.dart';

class AuthService {
  final BuildContext context;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late AuthCredential _authCredential;
  final User _firebaseUser = FirebaseAuth.instance.currentUser!;
  late DocumentReference userDocRef;

  AuthService({required this.context}) {
    userDocRef = _db.collection("users").doc(uid);
  }

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
      _authCredential = EmailAuthProvider.credential(email: _firebaseUser.email!, password: password);
      await _firebaseUser.reauthenticateWithCredential(_authCredential);
      await userDocRef.delete();
      //need to also delete all other data related to user (user_statistics, user_items, user_achievements...)
      await _firebaseUser.delete();
      //need to sign out
      return {"result": true, "message": "User deleted."};
    } on FirebaseAuthException catch (e) {
      if (e.code == "wrong-password") {
        return {"result": false, "message": "Wrong password."};
      }
      return {"result": false, "message": "Account could not be deleted."};
    }
  }

  Future<Map<String, dynamic>> changeUsername(String reAuthPassword, String newUsername) async {
    try {
      _authCredential = EmailAuthProvider.credential(email: _firebaseUser.email!, password: reAuthPassword);
      await _firebaseUser.reauthenticateWithCredential(_authCredential);
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

  Future<Map<String, dynamic>> changeEmail(String reAuthPassword, String newEmail) async {
    try {
      _authCredential = EmailAuthProvider.credential(email: _firebaseUser.email!, password: reAuthPassword);
      await _firebaseUser.reauthenticateWithCredential(_authCredential);
      await _firebaseUser.updateEmail(newEmail);
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

  Future<Map<String, dynamic>> changePassword(String reAuthPassword, String newPassword) async {
    try {
      _authCredential = EmailAuthProvider.credential(email: _firebaseUser.email!, password: reAuthPassword);
      await _firebaseUser.reauthenticateWithCredential(_authCredential);
      await _firebaseUser.updatePassword(newPassword);
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
