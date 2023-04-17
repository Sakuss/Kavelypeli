import 'package:flutter/material.dart';
import '../widgets/bar_chart_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StatsScreen extends StatefulWidget {
  StatsScreen({Key? key}) : super(key: key);
  final List<BarChartModel> data = [
    BarChartModel(
      month: "January",
      steps: 200000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "February",
      steps: 200000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "March",
      steps: 200000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "April",
      steps: 200000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "May",
      steps: 200000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "June",
      steps: 200000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "July",
      steps: 200000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "August",
      steps: 200000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "September",
      steps: 200000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "October",
      steps: 200000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "November",
      steps: 200000,
      color: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    BarChartModel(
      month: "December",
      steps: 200000,
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
        title: const Text("Bar Chart"),
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

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
