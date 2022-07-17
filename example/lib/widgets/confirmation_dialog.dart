import 'package:flutter/material.dart';

import 'buttons.dart';

class ConfirmationDialog extends StatefulWidget {
  const ConfirmationDialog({
    Key? key,
    required this.color,
    this.message,
    this.body,
    required this.actionName,
  })  : assert(
          message != null || body != null,
          '''You should at least provde [message] or body to explain to the user the context of this confirmation''',
        ),
        super(key: key);

  final Color color;
  final String? message;
  final Widget? body;
  final String actionName;

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: widget.body ?? Text(widget.message!),
      title: const Text('Are you sure?'),
      actions: [
        Button('Cancel', onTap: () => Navigator.pop<bool>(context, false)),
        DangerButton(
          widget.actionName,
          onTap: () {
            Navigator.pop<bool>(context, true);
          },
        ),
      ],
    );
  }
}
