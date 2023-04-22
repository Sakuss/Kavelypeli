import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:kavelypeli/util.dart';
import 'package:kavelypeli/widgets/pagecontainer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

import './screens/signin_screen.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);
  final User? _firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  void initState() {
    super.initState();
    checkPermissions();
    _initPlatformState();
  }

  void _initPlatformState() async {
    print("USER ${widget._firebaseUser}");
    if (widget._firebaseUser == null) {
      Util().loadFromPrefs("darkMode").then((value) {
        changeTheme(value == "true" ? ThemeMode.dark : ThemeMode.light);
      });
    } else {
      try {
        FirebaseFirestore.instance.collection("user_settings").doc(widget._firebaseUser!.uid).get().then((snapshot) {
          changeTheme(snapshot["darkMode"] as bool ? ThemeMode.dark : ThemeMode.light);
        });
      } catch (_) {}
    }
  }

  Future<void> checkPermissions() async {
    PermissionStatus locationStatus = await Permission.location.status;
    PermissionStatus activityStatus = await Permission.activityRecognition.status;
    if (locationStatus != PermissionStatus.granted || activityStatus != PermissionStatus.granted) {
      requestPermissions();
    }
  }

  Future<void> requestPermissions() async {
    PermissionStatus locationStatus = await Permission.location.request();
    PermissionStatus activityStatus = await Permission.activityRecognition.request();
    if (locationStatus == PermissionStatus.denied || activityStatus == PermissionStatus.denied) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: widget._firebaseUser == null
          ? SignIn(changeTheme: changeTheme)
          : FutureBuilder(
              future: AppUser.createUserWithUid(widget._firebaseUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return PageContainer(
                    user: snapshot.data!,
                    changeTheme: changeTheme,
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
    );
  }
}
