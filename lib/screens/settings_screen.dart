import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kavelypeli/main.dart';
import 'package:kavelypeli/services/auth_service.dart';
import 'package:kavelypeli/widgets/input_dialog.dart';

import '../models/menu_item_model.dart';
import '../util.dart';

class SettingsScreen extends StatefulWidget {
  final Function changeTheme;

  SettingsScreen({super.key, required this.changeTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _stepGoal = "10000", _valueText = "", _valueTextPassword = "";
  bool _darkMode = false;
  final _textFieldController = TextEditingController();
  final _textFieldPasswordController = TextEditingController();
  late AuthService _authService;
  late final List<MenuItem> _accountSettings = [
    MenuItem(
      title: "Change username",
      icon: Icons.person,
      iconColor: Colors.blue,
      onTap: () => _changeUsername(),
    ),
    MenuItem(
      title: "Change email",
      icon: Icons.email,
      iconColor: Colors.blue,
      onTap: () => _changeEmail(),
    ),
    MenuItem(
      title: "Change password",
      icon: Icons.password,
      iconColor: Colors.blue,
      onTap: () => _changePassword(),
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
    print("SETTINGS : initPlatformState");
    _authService = AuthService();
    _stepGoal = await Util().loadFromPrefs("stepGoal") ?? "10000";
    _darkMode = await Util().loadFromPrefs("darkMode") == "true";
    _darkMode
        ? widget.changeTheme(ThemeMode.dark)
        : widget.changeTheme(ThemeMode.light);

    setState(() {});
    print("$_darkMode, ${_darkMode.runtimeType}");
  }

  Future<String?> _showInputDialog(InputDialog inputDialog) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return inputDialog;
      },
    );
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
                _valueText = value;
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
                    if (int.parse(_valueText) >= 0 && _valueText != "") {
                      _stepGoal = _valueText;
                      Util().saveToPrefs("stepGoal", _stepGoal);
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

  void _deleteUserPasswordDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Type your password'),
          content: TextField(
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            onChanged: (value) {
              setState(() {
                _valueTextPassword = value;
              });
            },
            controller: _textFieldPasswordController,
            decoration: const InputDecoration(hintText: "Password"),
            // maxLength: 5,
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
                  Navigator.pop(context);
                  // _deleteUser(_valueTextPassword);
                  _deleteUser();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _changePassword() async {
    await _showInputDialog(
      const InputDialog(
        title: "Re-authenticate",
        inputDecorator: "Type your password",
        keyboardType: TextInputType.visiblePassword,
      ),
    ).then(
      (value) {
        print(value);
        // if (value != null) {
        //   final result = _authService.changeUsername(value);
        //   if (result) {
        //     Util().showSnackBar(context, "$value is your new username");
        //   } else {
        //     Util().showSnackBar(context, "Could not update username");
        //   }
        // }
      },
    );
    await _showInputDialog(
      const InputDialog(
        title: "Change password",
        inputDecorator: "New password",
        keyboardType: TextInputType.visiblePassword,
      ),
    ).then(
      (value) {
        print(value);
        // if (value != null) {
        //   final result = _authService.changeUsername(value);
        //   if (result) {
        //     Util().showSnackBar(context, "$value is your new username");
        //   } else {
        //     Util().showSnackBar(context, "Could not update username");
        //   }
        // }
      },
    );
  }

  void _changeEmail() async {
    final pass = await _reAuthenticate();
    print("PASSWORD : $pass");
    if (pass == null || pass == "") {
      return;
    }
    await _showInputDialog(
      InputDialog(
        title: "Change email",
        inputDecorator: "New email",
        keyboardType: TextInputType.emailAddress,
        inputFormatters: [FilteringTextInputFormatter.allow(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")],
      ),
    ).then(
      (newEmail) async {
        if (newEmail != null) {
          await _authService.changeEmail(pass, newEmail).then(
            (result) {
              if (result["result"]) {
                Util().showSnackBar(context, "Email changed");
              } else {
                Util().showSnackBar(context, result["message"]);
              }
            },
          );
        }
      },
    );
  }

  void _changeUsername() async {
    final pass = await _reAuthenticate();
    print("PASSWORD : $pass");
    if (pass == null || pass == "") {
      return;
    }
    await _showInputDialog(
      const InputDialog(
        title: "Change username",
        inputDecorator: "New username",
        keyboardType: TextInputType.text,
      ),
    ).then(
      (newUsername) async {
        if (newUsername != null) {
          await _authService.changeUsername(pass, newUsername).then(
            (result) {
              if (result["result"]) {
                Util()
                    .showSnackBar(context, "$newUsername is your new username");
              } else {
                Util().showSnackBar(context, result["message"]);
              }
            },
          );
        }
      },
    );
  }

  Future<String?> _reAuthenticate() async {
    final reAuthPassword = await _showInputDialog(
      const InputDialog(
        title: "Re-authenticate",
        inputDecorator: "Type your password",
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
      ),
    );
    print("REAUTHPASSWORD : $reAuthPassword");

    return reAuthPassword;
  }

  void _deleteUser() async {
    final pass = await _reAuthenticate();
    if (pass == null || pass == "") {
      return;
    }
    await _authService.deleteUser(pass).then((result) {
      if (result["result"]) {
        _clearCache();
        Util().showSnackBar(context, "User deleted");
        Navigator.pop(context);
      } else {
        Util().showSnackBar(context, result["message"]);
      }
    });
  }

  void _clearCache() {
    Util().clearPrefs();
    setState(() {
      _darkMode = false;
      widget.changeTheme(ThemeMode.light);
    });
    Util().showSnackBar(context, "Cache cleared");
  }

  void _darkModeHandler() {
    setState(() {
      _darkMode = _darkMode ? false : true;
    });
    print(_darkMode);
    Util().saveToPrefs("darkMode", _darkMode);
    widget.changeTheme(_darkMode ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
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
                  title: Text(_darkMode ? "Set light mode" : "Set dark mode"),
                  onTap: () => _darkModeHandler(),
                  // enabled: false,
                ),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.box,
                    color: Colors.red,
                  ),
                  title: const Text("Clear cache"),
                  onTap: () => _clearCache(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
