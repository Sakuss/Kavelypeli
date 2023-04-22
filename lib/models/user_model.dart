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
      await FirebaseFirestore.instance.collection('user_items').doc(user.uid).set({"items": []});
      await FirebaseFirestore.instance.collection('user_settings').doc(user.uid).set({"darkMode": false});
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'joinDate': user.metadata.creationTime,
        'steps': 0,
        'points': 0,
        'currency': 0,
        'stepGoal': 10000,
        'photoPath': 'profilepics/default.png'
      });
      var photoURL = await getPhotoURL('profilepics/default.png');
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

  static Future<String> getPhotoURL(String path) async {
    final storageRef = FirebaseStorage.instance.ref();
    String photoURL;
    try {
      final pathReference = storageRef.child(path);
      photoURL = await pathReference.getDownloadURL();
    } catch (e) {
      print(e);
      return "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";
    }
    return photoURL;
  }

  static Future<AppUser?> createUserWithUid(String uid) async {
    print("CREATING USER ...");
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final DocumentReference userDocument = db.collection('users').doc(uid);

      var userDocumentSnapshot = await userDocument.get();
      var firestoreUser = userDocumentSnapshot.data() as Map<String, dynamic>;
      var photoURL = await getPhotoURL(firestoreUser['photoPath']);

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

  static Future<AppUser?> createUserFromDocument(DocumentSnapshot document) async {
    try {
      var firestoreUser = document.data() as Map<String, dynamic>;
      var photoURL = await getPhotoURL(firestoreUser['photoPath']);

      return AppUser(
        username: firestoreUser['username'],
        email: firestoreUser['email'],
        photoURL: photoURL,
        joinDate: firestoreUser['joinDate'].toDate(),
        uid: document.id,
        steps: firestoreUser['steps'],
        points: firestoreUser['points'],
        currency: firestoreUser['currency'],
        stepGoal: firestoreUser["stepGoal"],
        userItems: await _getUserItems(document.id),
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<List<AppItem>> _getUserItems(String uid) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference userItemsDocRef = db.collection('user_items').doc(uid);

    List<AppItem> items = [];
    try {
      final itemsSnapshot = await userItemsDocRef.get();
      final Map<String, dynamic> data = itemsSnapshot.data() as Map<String, dynamic>;
      for (final item in data["items"]) {
        items.add(await AppItem.createItem(item));
      }
      return items;
    } catch (e) {
      print(e);
      return <AppItem>[];
    }
  }

  void saveItemsToDb() {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference userItemsDocRef = db.collection('user_items').doc(uid);

    try {
      db.runTransaction((transaction) async {
        List<Map<String, dynamic>> json = userItems!.map((item) => item.toJson()).toList();
        transaction.update(userItemsDocRef, {"items": json});
      }).whenComplete(() {
        print("User items updated");
      }).onError((error, stackTrace) {
        print(error);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateLocalUser() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference userDocRef = db.collection('users').doc(uid);

    try {
      final userSnapshot = await userDocRef.get();
      final Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      currency = userData["currency"];
      email = userData["email"];
      joinDate = userData["joinDate"].toDate();
      points = userData["points"];
      stepGoal = userData["stepGoal"];
      steps = userData["steps"];
      username = userData["username"];
      userItems = await _getUserItems(uid);
    } catch (e) {
      print(e);
    }
  }

  void saveUserToDb() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference userDocRef = db.collection('users').doc(uid);

    try {
      await userDocRef.update(toJson());
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "currency": currency,
      "email": email,
      "joinDate": joinDate,
      "points": points,
      "stepGoal": stepGoal,
      "steps": steps,
      "username": username,
    };
  }
}
