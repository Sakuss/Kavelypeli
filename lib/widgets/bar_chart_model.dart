import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;



class BarChartModel {
  String date;
  int steps;
  final charts.Color color;

  BarChartModel(
    {required this.date,
    required this.steps,
    required this.color,
    });
}
