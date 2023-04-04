import 'package:flutter/material.dart';

// class MenuItem {
//   final String title;
//   final String? subtitle;
//   final IconData icon;
//   final MaterialColor iconColor;
//   final Widget? trailing;
//   final VoidCallback? onTap;
//
//   MenuItem({
//     required this.title,
//     this.subtitle,
//     required this.icon,
//     required this.iconColor,
//     this.trailing,
//     required this.onTap,
//   });
//
//   ListTile get buildListTile {
//     return ListTile(
//       leading: Icon(icon, color: iconColor),
//       title: Text(title),
//       subtitle: subtitle != null ? Text(subtitle!) : null,
//       onTap: onTap,
//       trailing: trailing,
//     );
//   }
// }

class MenuItem extends StatefulWidget {
  final Text? title, subtitle;
  final IconData? icon;
  final MaterialColor? iconColor;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;

  const MenuItem({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.leading,
  });

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  @override
  void initState() {
    super.initState();
    // print(widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.leading,
      title: widget.title,
      subtitle: widget.subtitle,
      onTap: widget.onTap,
      trailing: widget.trailing,
    );
  }
}
