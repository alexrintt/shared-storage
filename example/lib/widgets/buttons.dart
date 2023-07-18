import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button(
    this.text, {
    super.key,
    this.color,
    required this.onTap,
  });

  final Color? color;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: color),
      onPressed: onTap,
      child: Text(text),
    );
  }
}

class DangerButton extends StatelessWidget {
  const DangerButton(
    this.text, {
    super.key,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Button(text, onTap: onTap, color: Colors.red);
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton(
    this.text, {
    super.key,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Button(text, onTap: onTap, color: Colors.blue);
  }
}
