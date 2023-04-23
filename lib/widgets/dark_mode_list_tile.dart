import 'package:flutter/material.dart';

class DarkModeListTile extends StatefulWidget {
  final VoidCallback darkModeCallback;
  final Widget leading;
  final Widget title;

  const DarkModeListTile(
      {Key? key,
      required this.darkModeCallback,
      required this.leading,
      required this.title})
      : super(key: key);

  @override
  State<DarkModeListTile> createState() => _DarkModeListTileState();
}

class _DarkModeListTileState extends State<DarkModeListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.leading,
      title: widget.title,
      onTap: () => widget.darkModeCallback(),
    );
  }
}
