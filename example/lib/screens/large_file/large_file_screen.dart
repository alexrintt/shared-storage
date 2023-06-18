import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_storage/shared_storage.dart';

import '../../theme/spacing.dart';
import '../../widgets/key_value_text.dart';

class LargeFileScreen extends StatefulWidget {
  const LargeFileScreen({super.key, required this.uri});

  final Uri uri;

  @override
  State<LargeFileScreen> createState() => _LargeFileScreenState();
}

class _LargeFileScreenState extends State<LargeFileScreen> {
  DocumentFile? _documentFile;
  StreamSubscription<Uint8List>? _subscription;
  int _bytesLoaded = 0;

  @override
  void initState() {
    super.initState();
    _loadDocFile();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDocFile() async {
    _documentFile = await widget.uri.toDocumentFile();

    setState(() {});

    _startLoadingFile();
  }

  Future<void> _startLoadingFile() async {
    final Stream<Uint8List> byteStream = getDocumentContentAsStream(widget.uri);

    _subscription = byteStream.listen(
      (bytes) {
        _bytesLoaded += bytes.length;
        // debounce2s(() => setState(() {}));
        setState(() {});
      },
      cancelOnError: true,
      onError: (_) => _unsubscribe(),
      onDone: _unsubscribe,
    );
  }

  void _unsubscribe() {
    _subscription?.cancel();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _documentFile?.name ?? 'Loading...',
        ),
      ),
      body: Center(
        child: ContentSizeCard(bytes: _bytesLoaded),
      ),
    );
  }
}

class ContentSizeCard extends StatelessWidget {
  const ContentSizeCard({super.key, required this.bytes});

  final int bytes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: k4dp.all,
        child: KeyValueText(
          entries: <String, Object>{
            'In bytes': '$bytes B',
            'In kilobytes': '${bytes ~/ 1024} KB',
            'In megabytes': '${bytes / 1024 ~/ 1024} MB',
            'In gigabytes': '${bytes / 1024 / 1024 ~/ 1024} GB',
            'In terabytes': '${bytes / 1024 / 1024 / 1024 ~/ 1014} TB',
          },
        ),
      ),
    );
  }
}
