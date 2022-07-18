import 'package:flutter/material.dart';

InlineSpan Function(Object) customStyleDecorator(TextStyle textStyle) {
  InlineSpan applyStyles(Object data) {
    if (data is String) {
      return TextSpan(
        text: data,
        style: textStyle,
      );
    }

    if (data is TextSpan) {
      return TextSpan(
        text: data.text,
        style: (data.style ?? const TextStyle()).merge(textStyle),
      );
    }

    return data as InlineSpan;
  }

  return applyStyles;
}

final bold = customStyleDecorator(const TextStyle(fontWeight: FontWeight.bold));
final italic =
    customStyleDecorator(const TextStyle(fontStyle: FontStyle.italic));
final red = customStyleDecorator(const TextStyle(color: Colors.red));
final normal = customStyleDecorator(const TextStyle());
