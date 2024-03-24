import 'package:flutter/material.dart';

class RoundedIconButton extends StatelessWidget {
  final Icon _icon;
  final Color _color;
  final VoidCallback onPressed;
  const RoundedIconButton({super.key, required Icon icon, required Color color, required this.onPressed})
      : _color = color,
        _icon = icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: _color,
      ),
      child: IconButton(
        icon: _icon,
        onPressed: onPressed,
        color: Colors.white,
      ),
    );
  }
}
