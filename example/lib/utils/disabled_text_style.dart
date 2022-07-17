import 'package:flutter/material.dart';

TextStyle disabledTextStyle() {
  return TextStyle(
    color: disabledColor(),
    fontStyle: FontStyle.italic,
  );
}

Color disabledColor() {
  return Colors.black26;
}
