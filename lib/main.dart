import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kavelypeli/widgets/signin.dart';
import 'widgets/pagecontainer.dart';

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

  static final List<Widget> widgets = <Widget>[
    const Text('Leaderboard'),
    const Text('Home'),
    const Text('Shop'),
  ];

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignIn(),
    );
  }
}
