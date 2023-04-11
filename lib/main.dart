import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kavelypeli/util.dart';
import 'package:kavelypeli/widgets/pagecontainer.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

import './screens/signin_screen.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Util().clearPrefs();
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
    _initPlatformState();
  }

  void _initPlatformState() async {
    await Util().loadFromPrefs("darkMode").then((value) {
      changeTheme(value == "true" ? ThemeMode.dark : ThemeMode.light);
    });
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
              future: AppUser.createUser(widget._firebaseUser!.uid),
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
