import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/menu_item_model.dart';
import '../util.dart';

class SettingsScreen extends StatefulWidget {
  final Function changeTheme;

  SettingsScreen({super.key, required this.changeTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _stepGoal = "10000", valueText = "";
  bool _darkMode = false;
  // final _loggedIn = true;
  final _textFieldController = TextEditingController();
  late FirebaseFirestore db;
  late final List<MenuItem> _accountSettings = [
    MenuItem(
      title: "Change username",
      icon: Icons.person,
      iconColor: Colors.blue,
      onTap: () => Util().showSnackBar(context, "Change username"),
    ),
    MenuItem(
      title: "Change password",
      icon: Icons.password,
      iconColor: Colors.blue,
      onTap: () => Util().showSnackBar(context, "Change password"),
    ),
    MenuItem(
      title: "Change email",
      icon: Icons.email,
      iconColor: Colors.blue,
      onTap: () => Util().showSnackBar(context, "Change email"),
    ),
    MenuItem(
      title: "Delete account",
      icon: Icons.delete,
      iconColor: Colors.red,
      onTap: () => _deleteUser(),
    ),
  ];

  // late final List<MenuItem> _appSettings = [
  //   MenuItem(
  //     title: "Set step goal",
  //     icon: FontAwesomeIcons.shoePrints,
  //     iconColor: Colors.blue,
  //     onTap: () => _displayTextInputDialog(),
  //   ),
  //   MenuItem(
  //     title: "Set dark mode",
  //     icon: FontAwesomeIcons.moon,
  //     iconColor: Colors.yellow,
  //     trailing: _darkModeSwitch,
  //     onTap: null,
  //   ),
  // ];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void initPlatformState() async {
    print("initPlatformState");
    // _darkMode = await Util().loadFromPrefs("darkMode") == "true";
    _darkMode = await Util().loadFromPrefs("darkMode") == "true";
    _darkMode
        ? widget.changeTheme(ThemeMode.dark)
        : widget.changeTheme(ThemeMode.light);
    setState(() {});
    print("$_darkMode, ${_darkMode.runtimeType}");
  }

  void _displayTextInputDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Step goal'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                valueText = value;
              });
            },
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Default: 10 000"),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              FilteringTextInputFormatter.deny(RegExp('^0+')),
            ],
            maxLength: 5,
          ),
          actions: <Widget>[
            MaterialButton(
              color: Colors.red,
              textColor: Colors.white,
              child: const Text('CANCEL'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            MaterialButton(
              color: Colors.green,
              textColor: Colors.white,
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  try {
                    if (int.parse(valueText) >= 0 && valueText != "") {
                      _stepGoal = valueText;
                      Util().saveToPrefs("stepGoal", _stepGoal.toString());
                    }
                    Util().showSnackBar(context, "New step goal is $_stepGoal");
                  } catch (e) {
                    Util().showSnackBar(
                        context, "Oops, couldn't update step goal.");
                    print("ERROR : $e");
                  }
                  print("STEP GOAL : $_stepGoal");
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteUser() async {
    Util().showSnackBar(context, "Delete user");
    db = FirebaseFirestore.instance;
    try {
      // var querySnapshot =
      //     await db.collection('users').where('username', isEqualTo: null).get();
      // print(querySnapshot.docs);
      // await db.runTransaction((transaction) async {
      //   await transaction.delete(querySnapshot);
      // });
    } catch (e) {
      print(e);
    }
  }

  void _clearCache() {
    Util().showSnackBar(context, "Cache cleared");
    Util().clearPrefs();
    setState(() {
      _darkMode = false;
      widget.changeTheme(ThemeMode.light);
    });
  }

  void _darkModeHandler() {
    setState(() {
      _darkMode = _darkMode ? false : true;
    });
    Util().saveToPrefs("darkMode", _darkMode);
    widget.changeTheme(_darkMode ? ThemeMode.dark : ThemeMode.light);
  }

  // Widget get _darkModeSwitch {
  //   print("_darkmodeswitch");
  //   return Switch(
  //     onChanged: (value) {
  //       setState(() {
  //         _darkMode = value;
  //       });
  //       widget.changeTheme(_darkMode ? ThemeMode.dark : ThemeMode.light);
  //       print(value);
  //       Util().saveToPrefs("darkMode", _darkMode);
  //     },
  //     value: _darkMode,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              "Account settings",
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return _accountSettings[index].buildListTile;
              },
              itemCount: _accountSettings.length,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    "Application settings",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.shoePrints,
                    color: Colors.blue,
                  ),
                  title: const Text("Set step goal"),
                  onTap: () => _displayTextInputDialog(),
                  // enabled: false,
                ),
                ListTile(
                  leading: FaIcon(
                    _darkMode ? FontAwesomeIcons.sun : FontAwesomeIcons.moon,
                    color: Colors.yellow,
                  ),
                  // trailing: _darkModeSwitch,
                  title: Text(_darkMode ? "Set light mode" : "Set dark mode"),
                  onTap: () => _darkModeHandler(),
                  // enabled: false,
                ),
                // ListTile(
                //   leading: const FaIcon(
                //     FontAwesomeIcons.moon,
                //     color: Colors.yellow,
                //   ),
                //   trailing: _darkModeSwitch,
                //   title: const Text("Set dark mode"),
                //   onTap: null,
                //   // enabled: false,
                // ),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.box,
                    color: Colors.red,
                  ),
                  title: const Text("Clear cache"),
                  onTap: () => _clearCache(),
                  // enabled: false,
                ),
              ],
            ),
          ),

          // Expanded(
          //   child: ListView.builder(
          //     physics: const BouncingScrollPhysics(),
          //     itemBuilder: (context, index) {
          //       return _appSettings[index].buildListTile;
          //     },
          //     itemCount: _appSettings.length,
          //   ),
          // ),
          // Expanded(
          //   child: ListTile(
          //     leading: const FaIcon(
          //       FontAwesomeIcons.moon,
          //       color: Colors.yellow,
          //     ),
          //     trailing: _darkModeSwitch,
          //     title: const Text("Set dark mode"),
          //     onTap: null,
          //     // enabled: false,
          //   ),
          // ),
        ],
      ),
    );
  }
}
