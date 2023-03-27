import 'package:flutter/material.dart';
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

  static const List<Widget> widgets = <Widget>[
    Text('Leaderboard'),
    Text('Home'),
    Text('Shop'),
  ];

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PageContainer(
        children: widgets,
      ),
    );
  }
}
