import 'dart:async';
import 'dart:convert';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_storage/shared_storage.dart';

import '../screens/large_file/large_file_screen.dart';
import '../theme/spacing.dart';
import '../widgets/buttons.dart';
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

      if (launched) {
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
    if (context.mounted) {
      final mimeTypeOrEmpty = type ?? '';

      if (!mimeTypeOrEmpty.startsWith(kTextMime) &&
          !mimeTypeOrEmpty.startsWith(kImageMime)) {
        return uri.openWithExternalApp();
      }

      await showModalBottomSheet(
        context: context,
        builder: (context) => DocumentContentViewer(documentFile: this),
      );
    }
  }
}

class DocumentContentViewer extends StatefulWidget {
  const DocumentContentViewer({super.key, required this.documentFile});

  final DocumentFile documentFile;

  @override
  State<DocumentContentViewer> createState() => _DocumentContentViewerState();
}

class _DocumentContentViewerState extends State<DocumentContentViewer> {
  Uint8List _bytes = Uint8List.fromList([]);
  StreamSubscription<Uint8List>? _subscription;
  int _bytesLoaded = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _startLoadingFile();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _unsubscribe() {
    _subscription?.cancel();
  }

  Future<void> _startLoadingFile() async {
    // The implementation of [getDocumentContent] is no longer blocking!
    // It now just merges all events of [getDocumentContentAsStream].
    // Basically: lazy loaded -> No performance issues.
    final Stream<Uint8List> byteStream =
        getDocumentContentAsStream(widget.documentFile.uri);

    _subscription = byteStream.listen(
      (Uint8List chunk) {
        _bytesLoaded += chunk.length;
        if (_bytesLoaded <= k1KB * 10) {
          // Load file
          _bytes = Uint8List.fromList(_bytes + chunk);
        } else {
          // otherwise just bump we are not going to display a large file
          _bytes = Uint8List.fromList([]);
        }

        setState(() {});
      },
      cancelOnError: true,
      onError: (_) {
        _loaded = true;
        _unsubscribe();
        setState(() {});
      },
      onDone: () {
        _loaded = true;
        _unsubscribe();
        setState(() {});
      },
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _bytesLoaded >= k1MB * 10) {
      // The ideal approach is to implement a backpressure using:
      // - Pause: _subscription!.pause();
      // - Resume: _subscription!.resume();
      // 'Backpressure' is a short term for 'loading only when the user asks for'.
      // This happens because there is no way to load a 5GB file into a variable and expect you app doesn't crash.
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Is done: $_loaded'),
            if (_bytesLoaded >= k1MB * 10)
              Text('File too long to show: ${widget.documentFile.name}'),
            ContentSizeCard(bytes: _bytesLoaded),
            Wrap(
              children: [
                ActionButton(
                  'Pause',
                  onTap: () {
                    if (_subscription?.isPaused == false) {
                      _subscription?.pause();
                    }
                  },
                ),
                ActionButton(
                  'Resume',
                  onTap: () {
                    if (_subscription?.isPaused == true) {
                      _subscription?.resume();
                    }
                  },
                ),
              ],
            )
          ],
        ),
      );
    }

    final type = widget.documentFile.type;
    final mimeTypeOrEmpty = type ?? '';

    final isImage = mimeTypeOrEmpty.startsWith(kImageMime);

    if (isImage) {
      return Image.memory(_bytes);
    }

    final contentAsString = utf8.decode(_bytes);

    final fileIsEmpty = contentAsString.isEmpty;

    return Container(
      padding: k8dp.all,
      child: Text(
        fileIsEmpty ? 'This file is empty' : contentAsString,
        style: fileIsEmpty ? disabledTextStyle() : null,
      ),
    );
  }
}
