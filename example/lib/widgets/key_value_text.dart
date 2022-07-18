import 'package:flutter/material.dart';

/// Use the entry value as [Widget] to use a [WidgetSpan] and [Text] to use a [TextSpan]
class KeyValueText extends StatefulWidget {
  const KeyValueText({Key? key, required this.entries}) : super(key: key);

  final Map<String, Object> entries;

  @override
  _KeyValueTextState createState() => _KeyValueTextState();
}

class _KeyValueTextState extends State<KeyValueText> {
  TextSpan _buildTextSpan(String key, Object value) {
    return TextSpan(
      children: [
        TextSpan(
          text: '$key: ',
        ),
        if (value is Widget)
          WidgetSpan(
            child: value,
            alignment: PlaceholderAlignment.middle,
          )
        else if (value is String)
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        const TextSpan(text: '\n'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          for (final key in widget.entries.keys)
            _buildTextSpan(
              key,
              widget.entries[key]!,
            ),
        ],
      ),
    );
  }
}
