import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  String uid;
  String? username, email;
  int steps, points, currency;
  DateTime? joinDate;
  String? photoUrl;

  AppUser({
    this.username,
    this.email,
    this.photoUrl,
    required this.joinDate,
    required this.uid,
    required this.steps,
    required this.points,
    required this.currency,
  });

  static Future<AppUser?> createUserOnSignup(
    User user,
    String username,
    String email,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'joinDate': user.metadata.creationTime,
        'steps': 0,
        'points': 0,
        'currency': 0,
      });
      return AppUser(
        username: username,
        email: email,
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

  static Future<AppUser?> createUserOnLogin(User user) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final DocumentReference userDocument = db.collection('users').doc(user.uid);

      var userDocumentSnapshot = await userDocument.get();
      var firestoreUser = userDocumentSnapshot.data() as Map<String, dynamic>;

      return AppUser(
        username: firestoreUser['username'],
        email: firestoreUser['email'],
        photoUrl: firestoreUser['photoUrl'],
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
