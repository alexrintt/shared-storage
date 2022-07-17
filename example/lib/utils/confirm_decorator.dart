import 'package:flutter/material.dart';

import '../widgets/confirmation_dialog.dart';
import 'inline_span.dart';

Future<bool> Function() confirm(
  BuildContext context,
  String action,
  VoidCallback callback, {
  List<InlineSpan>? message,
  String? text,
}) {
  assert(
    text != null || message != null,
    '''You should provide at least one [message] or [text]''',
  );
  Future<bool> openConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        color: Colors.red,
        actionName: action,
        body: Text.rich(
          TextSpan(
            children: [
              if (text != null) normal(text) else ...message!,
            ],
          ),
        ),
      ),
    );

    final confirmed = result == true;

    if (confirmed) callback();

    return confirmed;
  }

  return openConfirmationDialog;
}
