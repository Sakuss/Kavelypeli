import 'package:flutter/material.dart';
import 'package:kavelypeli/models/user_model.dart';
import 'package:kavelypeli/widgets/character_preview.dart';
import 'package:kavelypeli/widgets/map.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';

import '../util.dart';

class Home extends StatefulWidget {
  static const IconData icon = Icons.home;
  static const String name = "Home";
  final AppUser user;
  final int? stepGoal;

  const Home({Key? key, required this.user, required this.stepGoal})
      : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  late SharedPreferences prefs;
  String _status = "Unavailable";
  late int _steps, _points, _stepGoal;
  bool _isMapVisible = false;

  @override
  void initState() {
    print("HOME : initState");
    super.initState();
    _initPlatformState();
  }

  void _initPlatformState() async {
    widget.user.updateLocalUser();
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    // _steps = "Step Count not available";
    // _steps = '0';
    // _steps = await Util().loadFromPrefs("steps") ?? '0';
    // _stepGoal = '10000';
    // _stepGoal = await Util().loadFromPrefs("stepGoal") ?? '10000';
    setState(() {
      _points = widget.user.points;
      _steps = widget.user.steps;
      _stepGoal = widget.user.stepGoal ?? 10000;
      print(_stepGoal);
    });

    if (!mounted) return;
  }

  void onStepCount(StepCount event) {
    print(event);
    if (_steps != "Step Count not available") {
      setState(() {
        _steps = event.steps;
      });
      Util().saveToPrefs("steps", _steps);
    }
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

  double get _goalPct {
    try {
      double pct = _steps / _stepGoal;
      return pct < 0.0
          ? 0.0
          : pct > 1.0
              ? 1.0
              : pct;
    } catch (e) {
      print(e);
      return 0.0;
    }
  }

  void _addSteps() {
    setState(() {
      _steps = _steps + Util().generateStepsCount();
    });
    Util().saveToPrefs("steps", _steps);
  }

  void _reduceSteps() {
    setState(() {
      _steps = _steps - Util().generateStepsCount();
    });
    Util().saveToPrefs("steps", _steps);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double boxSize = mediaQuery.size.width / 2 - 40;
    setState(() {
    //   _steps = widget.user.steps.toString();
      _stepGoal = widget.stepGoal ?? _stepGoal;
    });

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          Card(
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
                          Radius.circular(15),
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
                              margin: const EdgeInsets.all(5),
                              child: const FaIcon(FontAwesomeIcons.shoePrints,
                                  size: 30),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "$_steps",
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
                          Radius.circular(15),
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
                              "$_points",
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: Container(
                          width: mediaQuery.size.width,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                            border: Border.all(
                              width: 5,
                              color: Colors.blue,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: _steps != "Step Count not available"
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 5.0),
                                      child: Text(
                                        "$_steps / $_stepGoal",
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10.0,
                                      ),
                                      child: LinearPercentIndicator(
                                        animation: true,
                                        lineHeight: 20.0,
                                        animationDuration: 500,
                                        percent: _goalPct,
                                        center: Text(
                                          _goalPct <= 1.0
                                              ? "${(_goalPct * 100).toStringAsFixed(2)} %"
                                              : "Goal achieved!",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        barRadius: const Radius.circular(5),
                                        progressColor: Colors.blueAccent,
                                        addAutomaticKeepAlive: false,
                                      ),
                                    ),
                                  ],
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "$_steps",
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: <Widget>[
                      //     ElevatedButton(
                      //       onPressed: _addSteps,
                      //       child: const Text("Add steps"),
                      //     ),
                      //     ElevatedButton(
                      //       onPressed: _reduceSteps,
                      //       child: const Text("Reduce steps"),
                      //     ),
                      //   ],
                      // ),
                    ),
                  ],
                ),
              ],
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
                        onPressed: null,
                        // onPressed: () => {
                        //   setState(() {
                        //     _isMapVisible = true;
                        //   })
                        // },
                        icon: const Icon(Icons.map),
                        iconSize: 30,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      // child: CharacterPreview(user: widget.user),
                      child: _isMapVisible
                          ? const MapWidget()
                          : CharacterPreview(user: widget.user),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
