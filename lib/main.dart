import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kavelypeli/util.dart';
import 'package:kavelypeli/screens/signin_screen.dart';
import 'package:kavelypeli/screens/shop_screen.dart';
import 'package:kavelypeli/screens/friends_screen.dart';
import 'widgets/pagecontainer.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Util().clearPrefs();
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   static const List<Widget> widgets = <Widget>[
//     SettingsScreen(),
//     Home(),
//     Text('Shop'),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.blue),
//       darkTheme: ThemeData.dark(),
//       themeMode: null,
//       home: PageContainer(
//         children: widgets,
//       ),
//     );
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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

  late List<Widget> widgets = <Widget>[
    // SettingsScreen(changeTheme: changeTheme),
    Text("Leaderboard"),
    Home(),
    ShopScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: SignIn(),
    );
  }
}
