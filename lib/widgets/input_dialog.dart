import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kavelypeli/util.dart';

enum Error {
  validInput,
  invalidInput,
  invalidEmail,
  invalidPassword,
  invalidUsername,
  passwordTooShort,
  usernameTooShort,
}

enum InputType {
  username,
  password,
  email,
}

class InputDialog extends StatefulWidget {
  final Text? title;
  final InputDecoration? inputDecoration;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final RegExp? regex;
  final int? minLength;
  final int? maxLength;
  final InputType? inputType;

  const InputDialog({
    super.key,
    this.title,
    this.inputDecoration,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText,
    this.regex,
    this.minLength,
    this.maxLength,
    this.inputType,
  });

  // static Future<String?> showInputDialog(BuildContext context, InputDialog inputDialog) async {
  //   return await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return inputDialog;
  //     },
  //   );
  // }

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  String _valueText = "";
  Error? error;

  @override
  void initState() {
    super.initState();
    print("INPUTDIALOG : INITSTATE");
  }

  Error? _checkInput(String input) {
    if (widget.inputType != null) {
      if (widget.minLength != null) {
        if (_valueText.characters.length < widget.minLength!) {
          switch (widget.inputType) {
            case InputType.username:
              return Error.usernameTooShort;
            case InputType.password:
              return Error.passwordTooShort;
            case InputType.email:
              break;
            case null:
              break;
          }
        }
      }
    }
    if (widget.regex == null) {
      return null;
    } else {
      if (widget.regex!.hasMatch(_valueText)) {
        return Error.validInput;
      } else {
        return Error.invalidInput;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      content: TextField(
        keyboardType: widget.keyboardType,
        onChanged: (value) {
          setState(() {
            _valueText = value;
          });
        },
        controller: _textEditingController,
        decoration: widget.inputDecoration,
        inputFormatters: widget.inputFormatters,
        obscureText: widget.obscureText ?? false,
        maxLength: widget.maxLength,
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
          onPressed: () {
            setState(() {
              error = _checkInput(_valueText);

              switch (error) {
                case Error.validInput:
                  Navigator.pop(context, _valueText);
                  break;
                case Error.invalidInput:
                  Util().showSnackBar(context, "Invalid input");
                  break;
                case Error.invalidUsername:
                  Util().showSnackBar(context, "Invalid username");
                  break;
                case Error.invalidPassword:
                  Util().showSnackBar(context, "Invalid password");
                  break;
                case Error.invalidEmail:
                  Util().showSnackBar(context, "Invalid email");
                  break;
                case Error.usernameTooShort:
                  Util().showSnackBar(context, "Username too short");
                  break;
                case Error.passwordTooShort:
                  Util().showSnackBar(context, "Password too short");
                  break;
                case null:
                  Navigator.pop(context, _valueText);
                  break;
              }
              _textEditingController.text = "";
            });
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
