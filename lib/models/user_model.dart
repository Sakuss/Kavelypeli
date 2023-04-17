import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AppUser {
  String uid;
  String? username, email;
  int steps, points;
  int? currency;
  DateTime? joinDate;
  String photoURL;

  AppUser({
    this.username,
    this.email,
    required this.photoURL,
    required this.joinDate,
    required this.uid,
    required this.steps,
    required this.points,
    this.currency,
  });

  static Future<AppUser?> createUserOnSignup(
    User user,
    String username,
    String email,
  ) async {
    try {
      // await user.updateDisplayName(username);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'joinDate': user.metadata.creationTime,
        'steps': 0,
        'points': 0,
        'currency': 0,
      });
      var photoURL = await getPhotoURL(user.uid);
      return AppUser(
        username: username,
        email: email,
        photoURL: photoURL,
        joinDate: user.metadata.creationTime,
        uid: user.uid,
        steps: 0,
        points: 0,
        currency: 0,
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<String> getPhotoURL(String uid) async {
    final storageRef = FirebaseStorage.instance.ref();
    String photoURL;
    try {
      final pathReference = storageRef.child('profilepics/$uid');
      photoURL = await pathReference.getDownloadURL();
    } catch (e) {
      final pathReference = storageRef.child('profilepics/default.png');
      photoURL = await pathReference.getDownloadURL();
    }
    return photoURL;
  }

  static Future<AppUser?> createUser(String uid) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final DocumentReference userDocument = db.collection('users').doc(uid);

      var userDocumentSnapshot = await userDocument.get();
      var firestoreUser = userDocumentSnapshot.data() as Map<String, dynamic>;
      var photoURL = await getPhotoURL(uid);

      return AppUser(
        username: firestoreUser['username'],
        email: firestoreUser['email'],
        photoURL: photoURL,
        joinDate: firestoreUser['joinDate'].toDate(),
        uid: userDocumentSnapshot.id,
        steps: firestoreUser['steps'],
        points: firestoreUser['points'],
        currency: firestoreUser['currency'],
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "uid": uid,
      "email": email,
      "steps": steps,
      "points": points,
    };
  }
}
