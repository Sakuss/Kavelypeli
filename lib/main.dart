import 'package:flutter/material.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const List<Widget> widgets = <Widget>[
    SettingsScreen(),
    Home(),
    Text('Shop'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      home: PageContainer(
        children: widgets,
      ),
    );
  }
}
