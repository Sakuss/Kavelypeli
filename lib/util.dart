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
  // void clearPrefs() async =>
  //     await SharedPreferences.getInstance().then((value) => value.clear());

  void saveToPrefs(String key, dynamic value) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value.toString());
  }
  // void saveToPrefs(String key, dynamic value) async =>
  //     await SharedPreferences.getInstance()
  //         .then((value) => value.setString(key, value.toString()));

  Future loadFromPrefs(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }
  // Future loadFromPrefs(String key) async =>
  //     await SharedPreferences.getInstance().then((value) => value.get(key));

  void deleteFromPrefs(String key) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
  // void deleteFromPrefs(String key) async =>
  //     await SharedPreferences.getInstance().then((value) => value.remove(key));

  void printPrefs() async {
    prefs = await SharedPreferences.getInstance();
    print(prefs.getKeys());
  }
  // void printPrefs() async => await SharedPreferences.getInstance()
  //     .then((value) => print(() => value.getKeys()));

  String generateStepsCount() {
    double minVal = 500;
    double maxVal = 1999;

    Random rand = Random();

    return (rand.nextDouble() * (maxVal - minVal) + minVal).round().toString();
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
