import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kavelypeli/models/item_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AppUser {
  String uid;
  String? username, email;
  int steps, points;
  int? currency, stepGoal;
  DateTime? joinDate;
  String photoURL;
  List<AppItem>? userItems;

  AppUser({
    this.username,
    this.email,
    this.currency,
    this.stepGoal,
    this.userItems,
    required this.photoURL,
    required this.joinDate,
    required this.uid,
    required this.steps,
    required this.points,
  });

  static Future<AppUser?> createUserOnSignup(
    User user,
    String username,
    String email,
  ) async {
    try {
      // await user.updateDisplayName(username);
      await FirebaseFirestore.instance
          .collection('user_items')
          .doc(user.uid)
          .set({"items": []});
      await FirebaseFirestore.instance
          .collection('user_settings')
          .doc(user.uid)
          .set({"darkMode": false});
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'joinDate': user.metadata.creationTime,
        'steps': 0,
        'points': 0,
        'currency': 0,
        'stepGoal': 10000,
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
        stepGoal: 10000,
        userItems: <AppItem>[],
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
    print("CREATING USER ...");
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final DocumentReference userDocument = db.collection('users').doc(uid);

      var userDocumentSnapshot = await userDocument.get();
      var firestoreUser = userDocumentSnapshot.data() as Map<String, dynamic>;
      var photoURL = await getPhotoURL(uid);
      List<AppItem> items = await _getUserItems(uid);
      print(items);
      // print(await _getUserItems(uid));

      return AppUser(
        username: firestoreUser['username'],
        email: firestoreUser['email'],
        photoURL: photoURL,
        joinDate: firestoreUser['joinDate'].toDate(),
        uid: userDocumentSnapshot.id,
        steps: firestoreUser['steps'],
        points: firestoreUser['points'],
        currency: firestoreUser['currency'],
        stepGoal: firestoreUser["stepGoal"],
        userItems: await _getUserItems(uid),
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<List<AppItem>> _getUserItems(String uid) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference userItemsDocRef =
        db.collection('user_items').doc(uid);

    List<AppItem> items = [];
    try {
      final itemsSnapshot = await userItemsDocRef.get();
      final Map<String, dynamic> data =
          itemsSnapshot.data() as Map<String, dynamic>;
      for (final item in data["items"]) {
        items.add(await AppItem.createItem(item));
      }
      print("item name : ${items[0].shopImage}");
      return items;
    } catch (e) {
      print(e);
      return <AppItem>[];
    }
  }

  // Future<List<AppItem>> getUserItems() async {
  //   final FirebaseFirestore db = FirebaseFirestore.instance;
  //   final DocumentReference userItemsDocRef =
  //   db.collection('user_items').doc(uid);
  //
  //   try {
  //     return userItemsDocRef.get().then((itemsSnapshot) {
  //       final Map<String, dynamic> data =
  //       (itemsSnapshot.data() as Map<String, dynamic>);
  //       List<AppItem> items = [];
  //       for (final item in data["items"]) {
  //         items.add(AppItem.createItem(item));
  //       }
  //       return items;
  //     });
  //   } catch (e) {
  //     print(e);
  //     return [];
  //   }
  // }

  void updateLocalUser() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference userDocRef = db.collection('users').doc(uid);

    try {
      final userSnapshot = await userDocRef.get();
      final Map<String, dynamic> data =
          userSnapshot.data() as Map<String, dynamic>;

      currency = data["currency"];
      email = data["email"];
      joinDate = data["joinDate"].toDate();
      points = data["points"];
      stepGoal = data["stepGoal"];
      steps = data["steps"];
      username = data["username"];
    } catch (e) {
      print(e);
    }
  }
}
