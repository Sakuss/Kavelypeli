import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kavelypeli/widgets/map.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import '../util.dart';

class Home extends StatefulWidget {
  static const IconData icon = Icons.home;
  static const String name = "Home";

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  late SharedPreferences prefs;
  late String _status = '?', _steps = "0", _points = "0", _stepGoal = "10000";
  late bool _isMapVisible = false;

  @override
  void initState() {
    super.initState();
    print("HOME : initState");
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    print(event);
    if (_steps != "Step Count not available") {
      // Util().saveToPrefs("steps", _steps);
    }
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
    print("STATUS : $_status");
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      // _steps = 'Step Count not available';
    });
  }

  void initPlatformState() async {
    print("HOME : initPlatformState");
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    _steps = await Util().loadFromPrefs("steps") ?? '0';
    _stepGoal = await Util().loadFromPrefs("stepGoal") ?? '10000';
    _points = Util().generateStepsCount();

    if (!mounted) return;
  }

  double get _goalPct {
    try {
      double pct = int.parse(_steps) / int.parse(_stepGoal);
      return pct < 0.0 ? 0.0 : pct;
    } catch (e) {
      print(e);
      return 0.0;
    }
  }

  void _addSteps() {
    setState(() {
      _steps = (int.parse(_steps) + int.parse(Util().generateStepsCount()))
          .toString();
    });
    Util().saveToPrefs("steps", _steps);
  }

  void _reduceSteps() {
    setState(() {
      _steps = (int.parse(_steps) - int.parse(Util().generateStepsCount()))
          .toString();
    });
    Util().saveToPrefs("steps", _steps);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double boxSize = mediaQuery.size.width / 2 - 40;

    return Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          Container(
            child: Card(
              elevation: 3,
              child: Column(
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
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.all(5),
                                child: const FaIcon(FontAwesomeIcons.shoePrints,
                                    size: 30),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                _steps,
                                style: _steps == "Step Count not available"
                                    ? const TextStyle(fontSize: 20)
                                    : const TextStyle(fontSize: 40),
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
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                child: const FaIcon(FontAwesomeIcons.solidStar,
                                    size: 30),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                _points,
                                style: const TextStyle(fontSize: 40),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        width: mediaQuery.size.width,
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: _steps != "Step Count not available"
                              ? LinearPercentIndicator(
                                  animation: true,
                                  lineHeight: 20.0,
                                  leading: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(_steps),
                                  ),
                                  trailing: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(_stepGoal),
                                  ),
                                  animationDuration: 500,
                                  percent: _goalPct <= 1 ? _goalPct : 1.0,
                                  center: _goalPct <= 1
                                      ? Text(
                                          "${(_goalPct * 100).toStringAsFixed(2)} %")
                                      : const Text("Goal achieved!"),
                                  barRadius: const Radius.circular(5),
                                  progressColor: Colors.blueAccent,
                                )
                              : Text(_steps),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: _addSteps,
                            child: const Text("Add steps"),
                          ),
                          ElevatedButton(
                            onPressed: _reduceSteps,
                            child: const Text("Reduce steps"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Card(
              elevation: 3,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        color: _isMapVisible ? null : Colors.blue,
                        onPressed: () => {
                          setState(() {
                            _isMapVisible = false;
                          })
                        },
                        icon: const Icon(Icons.person),
                        iconSize: 30,
                      ),
                      IconButton(
                        color: _isMapVisible ? Colors.blue : null,
                        onPressed: () => {
                          setState(() {
                            _isMapVisible = true;
                          })
                        },
                        icon: Icon(Icons.map),
                        iconSize: 30,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                        child: _isMapVisible
                            ? true
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : MapWidget()
                            : Text("Character here")),
                  ),
                ],
              ),
            ),
          ),
          // Expanded(
          //   child: CharacterRender(),
          // ),
        ],
      ),
    );
  }
}
