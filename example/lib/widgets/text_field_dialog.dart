import 'package:flutter/material.dart';

import '../utils/disabled_text_style.dart';
import 'buttons.dart';

class TextFieldDialog extends StatefulWidget {
  const TextFieldDialog({
    Key? key,
    required this.labelText,
    required this.hintText,
    this.suffixText,
    required this.actionText,
  }) : super(key: key);

  final String labelText;
  final String hintText;
  final String? suffixText;
  final String actionText;

  @override
  _TextFieldDialogState createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {
  late TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textFieldController = TextEditingController();
  }

  @override
  void dispose() {
    _textFieldController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        controller: _textFieldController,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          suffixText: widget.suffixText,
          suffixStyle: disabledTextStyle(),
        ),
      ),
      actions: <Widget>[
        Button(
          'Cancel',
          onTap: () => Navigator.pop<String>(context),
        ),
        Button(
          widget.actionText,
          onTap: () =>
              Navigator.pop<String>(context, _textFieldController.text),
        ),
      ],
    );
  }
}
