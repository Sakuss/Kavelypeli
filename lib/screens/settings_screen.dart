import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../util.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _loggedIn = true;
  String _stepGoal = "10000", valueText = "";
  final _textFieldController = TextEditingController();

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
                  } catch(e) {
                    Util().showSnackBar(context, "Oops, couldn't update step goal.");
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
        // width: MediaQuery.of(context).size.width,
        child: ListView(
          children: [
            Text("Account settings"),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              title: Text("Delete account"),
              onTap: () => Util().showSnackBar(context, "Account deleted"),
              enabled: _loggedIn,
            ),
            Text("Application settings"),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.shoePrints,
                color: Colors.blue,
              ),
              title: Text("Set step goal"),
              onTap: _displayTextInputDialog,
            ),
          ],
        ),
      ),
    );
  }
}
