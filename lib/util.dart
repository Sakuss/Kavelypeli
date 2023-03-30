import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Util {
  late SharedPreferences prefs;

  void saveToPrefs(String key, String value) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> loadFromPrefs(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  String generateStepsCount(){
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