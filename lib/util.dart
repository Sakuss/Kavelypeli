import 'dart:math';
import 'package:flutter/material.dart';

class Util {
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