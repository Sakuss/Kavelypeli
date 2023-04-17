import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kavelypeli/models/user_model.dart';
import 'package:kavelypeli/widgets/dark_mode_list_tile.dart';
import '../services/auth_service.dart';
import 'package:grouped_list/grouped_list.dart';

import '../widgets/input_dialog.dart';
import '../util.dart';

class SettingsScreen extends StatefulWidget {
  final Function changeTheme;
  final AppUser user;

  const SettingsScreen(
      {super.key, required this.changeTheme, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final DocumentReference userDocument =
      FirebaseFirestore.instance.collection('users').doc(widget.user.uid);
  late int _stepGoal = widget.user.stepGoal;
  bool _darkMode = false;
  late AuthService _authService;
  late final List<Map<String, dynamic>> _elements = [
    {
      "group": "Account settings",
      "element": ListTile(
        title: const Text("Change username"),
        leading: const Icon(Icons.person, color: Colors.blue),
        onTap: () => _changeUsername(),
      ),
    },
    {
      "group": "Account settings",
      "element": ListTile(
        title: const Text("Change email"),
        leading: const Icon(Icons.email, color: Colors.blue),
        onTap: () => _changeEmail(),
      ),
    },
    {
      "group": "Account settings",
      "element": ListTile(
        title: const Text("Change password"),
        leading: const Icon(Icons.password, color: Colors.blue),
        onTap: () => _changePassword(),
      ),
    },
    {
      "group": "Account settings",
      "element": ListTile(
        title: const Text("Delete account"),
        leading: const Icon(Icons.delete, color: Colors.red),
        onTap: () => _deleteUser(),
      ),
    },
    {
      "group": "Application settings",
      "element": ListTile(
        title: const Text("Set step goal"),
        leading: const FaIcon(
          FontAwesomeIcons.shoePrints,
          color: Colors.blue,
        ),
        onTap: () => _setStepGoal(),
      ),
    },
    {
      "group": "Application settings",
      "element": DarkModeListTile(
        leading: FaIcon(
          _darkMode ? FontAwesomeIcons.sun : FontAwesomeIcons.moon,
          color: Colors.yellow,
        ),
        title: Text(_darkMode ? "Set light mode" : "Set dark mode"),
        darkModeCallback: _darkModeHandler,
      ),
    },
    {
      "group": "Application settings",
      "element": ListTile(
        leading: const FaIcon(
          FontAwesomeIcons.box,
          color: Colors.red,
        ),
        title: const Text("Clear cache"),
        onTap: () => _clearCache(),
      ),
    },
  ];

  DarkModeListTile get darkModeTile {
    return DarkModeListTile(
      darkModeCallback: _darkModeHandler,
      leading: FaIcon(
        _darkMode ? FontAwesomeIcons.sun : FontAwesomeIcons.moon,
        color: Colors.yellow,
      ),
      title: Text(_darkMode ? "Set light mode" : "Set dark mode"),
    );
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    print("SETTINGS : initState");
  }

  void initPlatformState() async {
    _authService = AuthService(context: context);
    // _stepGoal = await Util().loadFromPrefs("stepGoal") ?? "10000";
    _darkMode = await Util().loadFromPrefs("darkMode") == "true";
    setState(() {
      _elements[5]["element"] = darkModeTile;
    });
    // _darkMode
    //     ? widget.changeTheme(ThemeMode.dark)
    //     : widget.changeTheme(ThemeMode.light);
  }

  Future<String?> _showInputDialog(InputDialog inputDialog) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return inputDialog;
      },
    );
  }

  void _changePassword() async {
    final pass = await _authService.reAuthenticate();
    if (pass == null || pass == "") {
      return;
    }
    await _showInputDialog(
      // await InputDialog.showInputDialog(
      //   context,
      const InputDialog(
        title: Text("Change password"),
        inputDecoration: InputDecoration(labelText: "New password"),
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        inputType: InputType.password,
        minLength: 5,
      ),
    ).then(
      (newPassword) async {
        if (newPassword != null) {
          await _authService.changePassword(pass, newPassword).then(
            (result) {
              if (result["result"]) {
                Util().showSnackBar(context, result["message"]);
              } else {
                Util().showSnackBar(context, result["message"]);
              }
            },
          );
        }
      },
    );
  }

  void _changeEmail() async {
    final pass = await _authService.reAuthenticate();
    print("PASSWORD : $pass");
    if (pass == null || pass == "") {
      return;
    }
    await _showInputDialog(
      InputDialog(
        title: const Text("Change email"),
        inputDecoration: const InputDecoration(labelText: "Email"),
        keyboardType: TextInputType.emailAddress,
        regex: RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"),
        inputType: InputType.email,
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
    final pass = await _authService.reAuthenticate();
    print("PASSWORD : $pass");
    if (pass == null || pass == "") {
      return;
    }
    await _showInputDialog(
      const InputDialog(
        title: Text("Change username"),
        inputDecoration: InputDecoration(labelText: "New username"),
        keyboardType: TextInputType.text,
        inputType: InputType.username,
        minLength: 5,
        maxLength: 20,
      ),
    ).then(
      (newUsername) async {
        if (newUsername != null) {
          await _authService.changeUsername(pass, newUsername).then(
            (result) {
              if (result["result"]) {
                Util().showSnackBar(context, result["message"]);
              } else {
                Util().showSnackBar(context, result["message"]);
              }
            },
          );
        }
      },
    );
  }

  void _deleteUser() async {
    final pass = await _authService.reAuthenticate();
    if (pass == null || pass == "") {
      return;
    }
    await _authService.deleteUser(pass).then((result) {
      if (result["result"]) {
        // _clearCache();
        Util().showSnackBar(context, result["message"]);
        Navigator.pop(context);
      } else {
        Util().showSnackBar(context, result["message"]);
      }
    });
  }

  void _setStepGoal() async {
    await _showInputDialog(
      InputDialog(
        title: const Text("Set step goal"),
        inputDecoration: const InputDecoration(labelText: "Step goal"),
        keyboardType: TextInputType.text,
        inputType: InputType.username,
        maxLength: 5,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          FilteringTextInputFormatter.deny(RegExp('^0+')),
        ],
      ),
    ).then(
      (value) {
        if (value != null && value != "") {
          try {
            if (int.parse(value) > 0) {
              print("stepGoal : $value");
              setState(() {
                _stepGoal = int.parse(value);
              });
              // Util().saveToPrefs("stepGoal", _stepGoal);
              userDocument.update({"stepGoal": int.parse(value)}).then((_) {
                widget.user.updateLocalUser();
              });
              Util().showSnackBar(context, "New step goal is $value");
            } else {
              Util().showSnackBar(context, "Step goal could not be set.");
            }
          } catch (e) {
            Util().showSnackBar(context, "Step goal could not be set.");
            print("ERROR : $e");
          }
        }
      },
    );
  }

  void _clearCache() {
    Util().clearPrefs();
    setState(() {
      // _stepGoal = 10000;
      _darkMode = false;
      _elements[5]["element"] = darkModeTile;
      widget.changeTheme(ThemeMode.light);
    });
    Util().showSnackBar(context, "Cache cleared");
  }

  void _darkModeHandler() {
    setState(() {
      _darkMode = !_darkMode;
      _elements[5]["element"] = darkModeTile;
    });
    Util().saveToPrefs("darkMode", _darkMode);
    widget.changeTheme(_darkMode ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Settings"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _stepGoal),
          )),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: GroupedListView(
          elements: _elements,
          groupBy: (element) => element["group"],
          groupSeparatorBuilder: (String value) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          itemBuilder: (c, element) {
            return Card(
              elevation: 8,
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: element["element"],
            );
          },
        ),
      ),
    );
  }
}
