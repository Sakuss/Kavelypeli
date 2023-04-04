import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../util.dart';

class AuthService {
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

  // AuthService({required this.firebaseUser});

  String? get uid => _firebaseUser.uid;

  String? get username => _firebaseUser.displayName;

  String? get email => _firebaseUser.email;

  void reAuthenticate() {}

  Future<Map<String, dynamic>> deleteUser(String password) async {
    try {
      final docRefUsers = _db.collection("users").doc(uid);
      _authCredential = EmailAuthProvider.credential(
          email: _firebaseUser.email!, password: password);
      await _firebaseUser.reauthenticateWithCredential(_authCredential);
      docRefUsers.update(updates);
      docRefUsers.delete().then((doc) {
        _firebaseUser.delete();
      });
      return {"result": true, "message": null};
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
      if (newUsername.length < 5) {
        throw FirebaseAuthException(code: "username-too-short");
      }
      _authCredential = EmailAuthProvider.credential(
          email: _firebaseUser.email!, password: reAuthPassword);
      await _firebaseUser.reauthenticateWithCredential(_authCredential);
      final docRefUsers = _db.collection("users").doc(uid);
      docRefUsers.update({"username": newUsername});
      return {"result": true, "message": null};
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
      if (!newEmail.contains('@')) {
        throw FirebaseAuthException(code: "invalid-email");
      }
      final docRefUsers = _db.collection("users").doc(uid);
      docRefUsers.update({"email": newEmail});
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

  Future<Map<String, dynamic>> changePassword(String newPassword) async {
    return {"result": false, "message": null};
  }
}
