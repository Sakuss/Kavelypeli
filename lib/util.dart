import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Util {
  late SharedPreferences prefs;

  void saveToPrefs(String key, final value) async {
    prefs = await SharedPreferences.getInstance();

    // _steps = int.parse(_steps) < 0 ? '0' : _steps;
    await prefs.setString(key, value);
  }

  Future<String?> loadFromPrefs(String key) async {
    prefs = await SharedPreferences.getInstance();
    final String? loadedValue = prefs.getString(key);
    return loadedValue;
    // print("LOADED STEPS : $loadedSteps");

    // if (loadedSteps != null) {
    //   _steps = int.parse(loadedSteps) < 0 ? '0' : loadedSteps;
    // } else {
    //   _steps = '0';
    // }
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