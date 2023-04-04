import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputDialog extends StatefulWidget {
  final String? title, inputDecorator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool? obscureText;

  const InputDialog({
    super.key,
    this.title,
    this.inputDecorator,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText,
  });

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  String _valueText = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title != null ? Text(widget.title!) : null,
      content: TextField(
        keyboardType: widget.keyboardType,
        onChanged: (value) {
          setState(() {
            _valueText = value;
          });
        },
        controller: _textEditingController,
        decoration: InputDecoration(hintText: widget.inputDecorator),
        inputFormatters: widget.inputFormatters,
        obscureText: widget.obscureText ?? false,
      ),
      actions: <Widget>[
        MaterialButton(
          color: Colors.red,
          textColor: Colors.white,
          child: const Text('CANCEL'),
          onPressed: () {
            setState(() {
              _textEditingController.text = "";
              Navigator.pop(context);
            });
          },
        ),
        MaterialButton(
          color: Colors.green,
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _textEditingController.text = "";
              Navigator.pop(context, _valueText);
            });
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
