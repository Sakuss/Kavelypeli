import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kavelypeli/main.dart';
import '../services/auth_service.dart';
import 'package:grouped_list/grouped_list.dart';

import '../widgets/input_dialog.dart';
import '../widgets/menu_item.dart';
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
      title: const Text("Change username"),
      leading: const Icon(Icons.person, color: Colors.blue),
      onTap: () => _changeUsername(),
    ),
    MenuItem(
      title: const Text("Change email"),
      leading: const Icon(Icons.email, color: Colors.blue),
      onTap: () => _changeEmail(),
    ),
    MenuItem(
      title: const Text("Change password"),
      leading: const Icon(Icons.password, color: Colors.blue),
      onTap: () => _changePassword(),
    ),
    MenuItem(
      title: const Text("Delete account"),
      leading: const Icon(Icons.delete, color: Colors.red),
      onTap: () => _deleteUser(),
    ),
  ];

  late final List<MenuItem> _appSettings = [
    MenuItem(
      title: const Text("Set step goal"),
      leading: const FaIcon(
        FontAwesomeIcons.shoePrints,
        color: Colors.blue,
      ),
      onTap: () => _setStepGoal(),
    ),
    MenuItem(
      leading: FaIcon(
        _darkMode ? FontAwesomeIcons.sun : FontAwesomeIcons.moon,
        color: Colors.yellow,
      ),
      title: Text(_darkMode ? "Set light mode" : "Set dark mode"),
      onTap: () => _darkModeHandler(),
    ),
    MenuItem(
      leading: const FaIcon(
        FontAwesomeIcons.box,
        color: Colors.red,
      ),
      title: const Text("Clear cache"),
      onTap: () => _clearCache(),
    ),
  ];

  late final List<Map<String, dynamic>> _elements = [
    {
      "group": "Account settings",
      "element": MenuItem(
        title: const Text("Change username"),
        leading: const Icon(Icons.person, color: Colors.blue),
        onTap: () => _changeUsername(),
      ),
    },
    {
      "group": "Account settings",
      "element": MenuItem(
        title: const Text("Change email"),
        leading: const Icon(Icons.email, color: Colors.blue),
        onTap: () => _changeEmail(),
      ),
    },
    {
      "group": "Account settings",
      "element": MenuItem(
        title: const Text("Change password"),
        leading: const Icon(Icons.password, color: Colors.blue),
        onTap: () => _changePassword(),
      ),
    },
    {
      "group": "Account settings",
      "element": MenuItem(
        title: const Text("Delete account"),
        leading: const Icon(Icons.delete, color: Colors.red),
        onTap: () => _deleteUser(),
      ),
    },
    {
      "group": "Application settings",
      "element": MenuItem(
        title: const Text("Set step goal"),
        leading: const FaIcon(
          FontAwesomeIcons.shoePrints,
          color: Colors.blue,
        ),
        onTap: () => _setStepGoal(),
      ),
    },
    // {
    //   "group": "Application settings",
    //   "element": MenuItem(
    //     leading: FaIcon(
    //       _darkMode ? FontAwesomeIcons.sun : FontAwesomeIcons.moon,
    //       color: Colors.yellow,
    //     ),
    //     title: Text(_darkMode ? "Set light mode" : "Set dark mode"),
    //     onTap: () => _darkModeHandler(),
    //   ),
    // },
    {
      "group": "Application settings",
      "element": MenuItem(
        leading: const FaIcon(FontAwesomeIcons.sun,
          color: Colors.yellow,
        ),
        title: const Text("Change theme"),
        onTap: () => _darkModeHandler(),
      ),
    },
    {
      "group": "Application settings",
      "element": MenuItem(
        leading: const FaIcon(
          FontAwesomeIcons.box,
          color: Colors.red,
        ),
        title: const Text("Clear cache"),
        onTap: () => _clearCache(),
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    print("SETTINGS : initState");
  }

  void initPlatformState() async {
    // print("SETTINGS : initPlatformState");
    _authService = AuthService();
    _stepGoal = await Util().loadFromPrefs("stepGoal") ?? "10000";
    _darkMode = await Util().loadFromPrefs("darkMode") == "true";
    _darkMode
        ? widget.changeTheme(ThemeMode.dark)
        : widget.changeTheme(ThemeMode.light);
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

  Future<String?> _reAuthenticate() async {
    final reAuthPassword = await _showInputDialog(
      const InputDialog(
        title: Text("Re-authenticate"),
        inputDecoration: InputDecoration(labelText: "Type your password"),
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        inputType: InputType.password,
      ),
    );
    print("REAUTHPASSWORD : $reAuthPassword");

    return reAuthPassword;
  }

  void _changePassword() async {
    final pass = await _reAuthenticate();
    print("PASSWORD : $pass");
    if (pass == null || pass == "") {
      return;
    }
    await _showInputDialog(
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
    final pass = await _reAuthenticate();
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
    final pass = await _reAuthenticate();
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
    final pass = await _reAuthenticate();
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
        if (value == null || value == "") {
          Util().showSnackBar(context, "Step goal could not be set.");
        } else {
          try {
            if (int.parse(value) > 0) {
              print("stepGoal : $value");
              setState(() {
                _stepGoal = value;
              });
              Util().saveToPrefs("stepGoal", _stepGoal);
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
      _darkMode = false;
      widget.changeTheme(ThemeMode.light);
    });
    Util().showSnackBar(context, "Cache cleared");
  }

  void _darkModeHandler() {
    setState(() {
      // _darkMode = _darkMode ? false : true;
      _darkMode = !_darkMode;
    });
    Util().saveToPrefs("darkMode", _darkMode);
    widget.changeTheme(_darkMode ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return Padding(
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
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: element["element"],
          );
        },
      ),
    );
  }

// @override
// Widget build(BuildContext context) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 10),
//     child: Column(
//       children: <Widget>[
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 10),
//           child: Text(
//             "Account settings",
//             style: TextStyle(fontSize: 20),
//           ),
//         ),
//         Expanded(
//           flex: 1,
//           child: ListView.builder(
//             physics: const BouncingScrollPhysics(),
//             itemBuilder: (context, index) {
//               return Card(
//                 elevation: 8,
//                 child: _accountSettings[index],
//               );
//             },
//             itemCount: _accountSettings.length,
//           ),
//         ),
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 10),
//           child: Text(
//             "Application settings",
//             style: TextStyle(fontSize: 20),
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             physics: const BouncingScrollPhysics(),
//             itemBuilder: (context, index) {
//               return Card(
//                 elevation: 8,
//                 child: _appSettings[index],
//               );
//             },
//             itemCount: _appSettings.length,
//           ),
//         ),
//         Expanded(
//           // flex: 2,
//           child: Column(
//             children: <Widget>[
//               const Padding(
//                 padding: EdgeInsets.only(top: 10),
//                 child: Text(
//                   "Application settings",
//                   style: TextStyle(fontSize: 20),
//                 ),
//               ),
//               ListTile(
//                 leading: const FaIcon(
//                   FontAwesomeIcons.shoePrints,
//                   color: Colors.blue,
//                 ),
//                 title: const Text("Set step goal"),
//                 onTap: () => _setStepGoal(),
//               ),
//               ListTile(
//                 leading: FaIcon(
//                   _darkMode ? FontAwesomeIcons.sun : FontAwesomeIcons.moon,
//                   color: Colors.yellow,
//                 ),
//                 title: Text(_darkMode ? "Set light mode" : "Set dark mode"),
//                 onTap: () => _darkModeHandler(),
//                 // enabled: false,
//               ),
//               ListTile(
//                 leading: const FaIcon(
//                   FontAwesomeIcons.box,
//                   color: Colors.red,
//                 ),
//                 title: const Text("Clear cache"),
//                 onTap: () => _clearCache(),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
}
