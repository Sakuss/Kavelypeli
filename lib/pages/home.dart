import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pedometer/pedometer.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double boxSize = mediaQuery.size.width / 2 - 20;

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(10),
              height: boxSize,
              width: boxSize,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(25),
                ),
                border: Border.all(
                  width: 5,
                  color: Colors.green,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: <Widget>[
                  const Expanded(
                    flex: 1,
                    child: Text(
                      "Steps",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      // _steps,
                      "123 321",
                      style: _steps == "Step Count not available"
                          ? TextStyle(fontSize: 40)
                          : TextStyle(fontSize: 40),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Icon(
                      _status == 'walking'
                          ? Icons.directions_walk
                          : _status == 'stopped'
                              ? Icons.accessibility_new
                              : Icons.error,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              height: boxSize,
              width: boxSize,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(25),
                ),
                border: Border.all(
                  width: 5,
                  color: Colors.yellow,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: <Widget>[
                  const Expanded(
                    flex: 1,
                    child: Text(
                      "Points",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Points",
                      style: const TextStyle(fontSize: 40),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
