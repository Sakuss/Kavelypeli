import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../util.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  Future<bool> deleteUser(String password) async {
    final docRefUsers = FirebaseFirestore.instance.collection("users").doc(uid);
    _authCredential = EmailAuthProvider.credential(
        email: _firebaseUser.email!, password: password);
    try {
      await _firebaseUser.reauthenticateWithCredential(_authCredential);
      docRefUsers.update(updates);
      docRefUsers.delete().then((doc) {
        _firebaseUser.delete();
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  bool changeUsername(String newUsername) {
    try {
      final docRefUsers = FirebaseFirestore.instance.collection("users").doc(uid);
      docRefUsers.update({"username": newUsername});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  bool changeEmail(String newEmail) {
    try {
      final docRefUsers = FirebaseFirestore.instance.collection("users").doc(uid);
      docRefUsers.update({"email": newEmail});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void changePassword(String newPassword) => _firebaseUser.updatePassword(newPassword);
}
