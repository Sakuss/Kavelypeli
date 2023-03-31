import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final MaterialColor iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  MenuItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.trailing,
    required this.onTap,
  });

  ListTile get buildListTile {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
      trailing: trailing,
    );
  }
}

// class MenuItem extends StatefulWidget {
//   final String title;
//   final String? subtitle;
//   final IconData icon;
//   final MaterialColor iconColor;
//   final Widget? trailing;
//   final VoidCallback? onTap;
//
//   MenuItem({super.key,
//     required this.title,
//     this.subtitle,
//     required this.icon,
//     required this.iconColor,
//     this.trailing,
//     required this.onTap,
//   });
//
//   @override
//   State<MenuItem> createState() => _MenuItemState();
// }
//
// class _MenuItemState extends State<MenuItem> {
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Icon(widget.icon, color: widget.iconColor),
//       title: Text(widget.title),
//       subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
//       onTap: widget.onTap,
//       trailing: widget.trailing,
//     );
//   }
// }

