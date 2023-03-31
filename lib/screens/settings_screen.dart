import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../util.dart';

class SettingsScreen extends StatefulWidget {
  final Function changeTheme;

  SettingsScreen({super.key, required this.changeTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _loggedIn = true;
  String _stepGoal = "10000", valueText = "";
  final _textFieldController = TextEditingController();
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void initPlatformState() async {
    _darkMode = await Util().loadFromPrefs("darkMode") == "true";
    _darkMode == true
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
          title: Text('Step goal'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                valueText = value;
              });
            },
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Default: 10 000"),
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
              child: Text('CANCEL'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            MaterialButton(
              color: Colors.green,
              textColor: Colors.white,
              child: Text('OK'),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        child: ListView(
          children: [
            const Text("Account settings"),
            ListTile(
              leading: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              title: const Text("Delete account"),
              onTap: () => Util().showSnackBar(context, "Account deleted"),
              enabled: _loggedIn,
            ),
            const Text("Application settings"),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.shoePrints,
                color: Colors.blue,
              ),
              title: const Text("Set step goal"),
              onTap: _displayTextInputDialog,
            ),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.moon,
                color: Colors.black,
              ),
              trailing: Switch(
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                  widget.changeTheme(
                      _darkMode ? ThemeMode.dark : ThemeMode.light);

                  Util().saveToPrefs("darkMode", _darkMode);
                },
                value: _darkMode,
              ),
              title: const Text("Set dark mode"),
              onTap: null,
              // enabled: false,
            ),
          ],
        ),
      ),
    );
  }
}
