import 'package:flutter/material.dart';
import '../widgets/bar_chart_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final List<BarChartModel> data = [
    BarChartModel(
      month: "Monday",
      steps: 10000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "Tuesday",
      steps: 10000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "Wednesday",
      steps: 10000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "Thursday",
      steps: 10000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "Friday",
      steps: 10000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "Saturday",
      steps: 10000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "Sunday",
      steps: 10000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    List<charts.Series<BarChartModel, String>> series = [
      charts.Series(
        id: "steps",
        data: data,
        domainFn: (BarChartModel series, _) => series.month,
        measureFn: (BarChartModel series, _) => series.steps,
        colorFn: (BarChartModel series, _) => series.color,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stats",
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
      ),
      body: Container(
          padding: const EdgeInsets.all(10),
          child: charts.BarChart(
            series,
            animate: true,
          )),
    );
  }
}
