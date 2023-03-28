import 'package:flutter/material.dart';
import 'widgets/pagecontainer.dart';
import './pages/home.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const List<Widget> widgets = <Widget>[
    Text('Leaderboard'),
    Home(),
    Text('Shop'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      fontFamily: "Quicksand",
      textTheme: ThemeData.light().textTheme.copyWith(
        titleMedium: const TextStyle(
          fontFamily: "Quicksand",
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        // button: TextStyle(
        //   color: Colors.white,
        // ),
      ),
    ),
      home: PageContainer(
        children: widgets,
      ),
    );
  }
}
