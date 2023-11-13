import 'dart:convert';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_storage/saf.dart';

import '../theme/spacing.dart';
import 'disabled_text_style.dart';
import 'mime_types.dart';

extension ShowText on BuildContext {
  Future<void> showToast(String text, {Duration? duration}) {
    return showTextToast(
      text: text,
      context: this,
      duration: const Duration(seconds: 5),
    );
  }
}

extension OpenUriWithExternalApp on Uri {
  Future<void> openWithExternalApp() async {
    final uri = this;

    try {
      final launched = await openDocumentFile(uri);

      if (launched ?? false) {
        print('Successfully opened $uri');
      } else {
        print('Failed to launch $uri');
      }
    } on PlatformException {
      print(
        "There's no activity associated with the file type of this Uri: $uri",
      );
    }
  }
}

extension ShowDocumentFileContents on DocumentFile {
  Future<void> showContents(BuildContext context) async {
    final mimeTypeOrEmpty = type ?? '';
    final sizeInBytes = size ?? 0;

    const k10mb = 1024 * 1024 * 10;

    if (!mimeTypeOrEmpty.startsWith(kTextMime) &&
        !mimeTypeOrEmpty.startsWith(kImageMime)) {
      return uri.openWithExternalApp();
    }

    // Too long, will take too much time to read
    if (sizeInBytes > k10mb) {
      return context.showToast('File too long to open');
    }

    final content = await getDocumentContent(uri);

    if (content != null) {
      final isImage = mimeTypeOrEmpty.startsWith(kImageMime);

      if (context.mounted) {
        await showModalBottomSheet(
          context: context,
          builder: (context) {
            if (isImage) {
              return Image.memory(content);
            }

            final contentAsString = utf8.decode(content);

            final fileIsEmpty = contentAsString.isEmpty;

            return Container(
              padding: k8dp.all,
              child: Text(
                fileIsEmpty ? 'This file is empty' : contentAsString,
                style: fileIsEmpty ? disabledTextStyle() : null,
              ),
            );
          },
        );
      }
    }
  }
}
