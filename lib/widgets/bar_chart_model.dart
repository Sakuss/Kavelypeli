import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;



class BarChartModel {
  String month;
  int steps;
  final charts.Color color;

  BarChartModel(
    {required this.month,
    required this.steps,
    required this.color,
    });
}
