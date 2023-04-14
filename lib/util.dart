import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Util {
  late SharedPreferences prefs;

  void clearPrefs() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void saveToPrefs(String key, dynamic value) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value.toString());
  }

  Future loadFromPrefs(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  void deleteFromPrefs(String key) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  void printPrefs() async {
    prefs = await SharedPreferences.getInstance();
    print(prefs.getKeys());
  }

  String generateStepsCount() {
    double minVal = 500;
    double maxVal = 1999;

    Random rand = Random();

    return (rand.nextDouble() * (maxVal - minVal) + minVal).round().toString();
  }

  void showSnackBar(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
