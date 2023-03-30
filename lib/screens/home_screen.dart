import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

import '../util.dart';
import '../widgets/character_render.dart';

class Home extends StatefulWidget {
  static const IconData icon = Icons.home;
  static const String name = "Home";

  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  late SharedPreferences prefs;
  String _status = '?', _steps = "", _points = "";
  final String _stepGoal = "20000";
  // final util = Util();

  @override
  void initState() {
    super.initState();
    // _loadSteps();
    _steps = _loadFromPrefs("steps") ?? '0';
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
    // _saveSteps();
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

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    _points = Util().generateStepsCount();

    if (!mounted) return;
  }

  double get _goalPct => double.parse(_steps) / double.parse(_stepGoal);

  void _addSteps() {
    setState(() {
      _steps = (int.parse(_steps) + int.parse(Util().generateStepsCount()))
          .toString();
    });
    // _saveSteps();
    _saveToPrefs("steps", _steps);
  }

  void _reduceSteps() {
    setState(() {
      _steps = (int.parse(_steps) - int.parse(Util().generateStepsCount()))
          .toString();
    });
    // _saveSteps();
    _saveToPrefs("steps", _steps);
  }

  void _saveToPrefs(String key, String value) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> _loadFromPrefs(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  void _saveSteps() async {
    prefs = await SharedPreferences.getInstance();

    _steps = int.parse(_steps) < 0 ? '0' : _steps;
    await prefs.setString("steps", _steps);
  }

  void _loadSteps() async {
    prefs = await SharedPreferences.getInstance();
    final String? loadedSteps = prefs.getString("steps");
    print("LOADED STEPS : $loadedSteps");

    if (loadedSteps != null) {
      _steps = int.parse(loadedSteps) < 0 ? '0' : loadedSteps;
    } else {
      _steps = '0';
    }
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
                                child: FaIcon(FontAwesomeIcons.shoePrints,
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
                                margin: EdgeInsets.all(5),
                                child: FaIcon(FontAwesomeIcons.solidStar,
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
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: LinearPercentIndicator(
                            animation: true,
                            lineHeight: 20.0,
                            leading: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(_steps),
                            ),
                            trailing: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(_stepGoal),
                            ),
                            animationDuration: 500,
                            percent: _goalPct <= 1 ? _goalPct : 1.0,
                            center: _goalPct <= 1
                                ? Text(
                                    "${(_goalPct * 100).toStringAsFixed(2)} %")
                                : const Text("Goal achieved!"),
                            barRadius: Radius.circular(5),
                            progressColor: Colors.greenAccent,
                          ),
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
          // Expanded(
          //   child: CharacterRender(),
          // ),
        ],
      ),
    );
  }
}
