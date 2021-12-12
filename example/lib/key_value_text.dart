import 'package:flutter/cupertino.dart';

class KeyValueText extends StatefulWidget {
  final Map<String, String> entries;

  const KeyValueText({Key? key, required this.entries}) : super(key: key);

  @override
  _KeyValueTextState createState() => _KeyValueTextState();
}

class _KeyValueTextState extends State<KeyValueText> {
  TextSpan _buildTextSpan(String key, String value) {
    return TextSpan(
      children: [
        TextSpan(
          text: '$key: ',
        ),
        TextSpan(
          text: '$value\n',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
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
              '${widget.entries[key]}',
            ),
        ],
      ),
    );
  }
}
