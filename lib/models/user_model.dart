import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kavelypeli/models/item_model.dart';

class AppUser {
  String uid;
  String? username, email;
  int steps, points, currency, stepGoal;
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
    // required this.itemDoc,
    required this.stepGoal,
  });

  static Future<AppUser?> createUserOnSignup(
    User user,
    String username,
    String email,
  ) async {
    try {
      // await user.updateDisplayName(username);
      final userItemsSnapshot = await FirebaseFirestore.instance
          .collection('user_items')
          .doc(user.uid)
          .set({"items": []});
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'joinDate': user.metadata.creationTime,
        'steps': 0,
        'points': 0,
        'currency': 0,
        'stepGoal': 10000,
      });
      return AppUser(
        username: username,
        email: email,
        joinDate: user.metadata.creationTime,
        uid: user.uid,
        steps: 0,
        points: 0,
        currency: 0,
        stepGoal: 10000,
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<AppUser?> createUser(String uid) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final DocumentReference userDocument = db.collection('users').doc(uid);

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
        stepGoal: firestoreUser["stepGoal"],
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<AppItem>> getUserItems() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference userItemsDocRef =
        db.collection('user_items').doc(uid);

    try {
      return userItemsDocRef.get().then((itemsSnapshot) {
        final Map<String, dynamic> data =
            (itemsSnapshot.data() as Map<String, dynamic>);
        List<AppItem> items = [];
        for (final item in data["items"]) {
          items.add(AppItem.createItem(item));
        }
        return items;
      });
    } catch (e) {
      print(e);
      return [];
    }
  }

  void updateLocalUser() {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference userDocRef = db.collection('users').doc(uid);

    try {
      userDocRef.get().then((userSnapshot) {
        final Map<String, dynamic> data =
            userSnapshot.data() as Map<String, dynamic>;

        currency = data["currency"];
        email = data["email"];
        joinDate = data["joinDate"].toDate();
        points = data["points"];
        stepGoal = data["stepGoal"];
        steps = data["steps"];
        username = data["username"];
      });
    } catch (e) {
      print(e);
    }
  }
}
