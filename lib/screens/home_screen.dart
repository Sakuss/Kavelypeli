import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kavelypeli/models/user_model.dart';
import 'package:kavelypeli/widgets/character_preview.dart';
import 'package:kavelypeli/widgets/map.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

import '../util.dart';

class Home extends StatefulWidget {
  static const IconData icon = Icons.home;
  static const String name = "Home";
  final AppUser user;
  final int? stepGoal;

  const Home({Key? key, required this.user, required this.stepGoal}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  late SharedPreferences prefs;
  String _pedestrianStatus = "Unavailable";
  String _stepCountStatus = "Unavailable";

  late int _stepsToday, _points;
  late final int _stepGoal = widget.user.stepGoal!;
  final int _pointsMultiplier = 5;
  bool _isMapVisible = false;
  final db = FirebaseFirestore.instance;
  late final DocumentReference userDocument = FirebaseFirestore.instance.collection('users').doc(widget.user.uid);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    print("HOME : initState");
    super.initState();
    _initPlatformState();
  }

  void _initPlatformState() async {
    updateUser();
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream.listen(onPedestrianStatusChanged).onError(((error) {
      print('onPedestrianStatusError: $error');
      setState(() {
        _pedestrianStatus = 'Pedestrian Status not available';
      });
    }));

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError((error) {
      print('onStepCountError: $error');
      setState(() {
        // _stepCountStatus = 'Step Count not available';
      });
    });
    _points = 0;
    _stepsToday = 0;
    var stepsToday = await Util().loadFromPrefs('stepsToday');
    if (stepsToday != null) {
      _stepsToday = int.parse(stepsToday);
    }
  }

  void updateUser() async {
    await widget.user.updateLocalUser();
    setState(() {
      _points = widget.user.points;
    });
  }

  bool isNotToday(DateTime lastSavedDate) {
    return lastSavedDate.day != DateTime.now().day;
  }

  void onStepCount(StepCount event) async {
    if (_stepCountStatus != "Step Count not available") {
      var lastSavedSteps = await Util().loadFromPrefs('lastSavedSteps');
      var lastSavedDate = await Util().loadFromPrefs('lastSavedDate');

      if (lastSavedSteps == null && lastSavedDate == null) {
        Util().saveToPrefs('lastSavedSteps', 0);
        Util().saveToPrefs('lastSavedDate', DateTime.now());
        lastSavedSteps = '0';
        lastSavedDate = DateTime.now().toString();
      }

      if (event.steps < int.parse(lastSavedSteps)) {
        Util().saveToPrefs('lastSavedSteps', 0);
      }

      if (_pedestrianStatus == 'walking') {
        var lastSteps = _stepsToday;

        setState(() {
          _stepsToday = event.steps - int.parse(lastSavedSteps);
        });
        var stepIncrement = _stepsToday - lastSteps;
        var pointsIncrement = stepIncrement * _pointsMultiplier;
        setState(() {
          _points += pointsIncrement;
        });
        userDocument.update({
          'steps': FieldValue.increment(stepIncrement),
          'points': FieldValue.increment(pointsIncrement),
        });
        Util().saveToPrefs('stepsToday', _stepsToday);
      }

      if (isNotToday(DateTime.parse(lastSavedDate))) {
        Util().saveToPrefs('lastSavedSteps', event.steps);
        Util().saveToPrefs('lastSavedDate', event.timeStamp);
        _stepsToday = 0;
      }
    }
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event.status);
    setState(() {
      _pedestrianStatus = event.status;
    });
  }

  double get _goalPct {
    try {
      double pct = _stepsToday / _stepGoal;
      return pct < 0.0
          ? 0.0
          : pct > 1.0
              ? 1.0
              : pct;
    } catch (_) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double boxSize = mediaQuery.size.width / 2 - 40;

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
                              child: const FaIcon(FontAwesomeIcons.shoePrints, size: 30),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "$_stepsToday",
                              style: _stepCountStatus == "Step Count not available"
                                  ? const TextStyle(fontSize: 20)
                                  : const TextStyle(fontSize: 40),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Icon(
                              _pedestrianStatus == 'walking'
                                  ? Icons.directions_walk
                                  : _pedestrianStatus == 'stopped'
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
                              child: const FaIcon(FontAwesomeIcons.solidStar, size: 30),
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
                          child: _stepCountStatus != "Step Count not available"
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                                      child: Text(
                                        "$_stepsToday / $_stepGoal",
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
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "$_stepsToday",
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
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
                      child: _isMapVisible ? const MapWidget() : CharacterPreview(user: widget.user),
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
