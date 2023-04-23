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
      date: "Mon",
      steps: 90,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      date: "Tue",
      steps: 100,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      date: "Wed",
      steps: 370,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      date: "Thu",
      steps: 90,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      date: "Fri",
      steps: 10,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      date: "Sat",
      steps: 40,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      date: "Sun",
      steps: 100,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    List<charts.Series<BarChartModel, String>> series = [
      charts.Series(
        id: "steps",
        data: data,
        domainFn: (BarChartModel series, _) => series.date,
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
