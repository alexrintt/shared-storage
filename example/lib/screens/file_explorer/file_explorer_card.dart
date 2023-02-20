import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_storage/shared_storage.dart';

import '../../utils/apply_if_not_null.dart';
import '../../utils/confirm_decorator.dart';
import '../../utils/disabled_text_style.dart';
import '../../utils/document_file_utils.dart';
import '../../utils/format_bytes.dart';
import '../../utils/inline_span.dart';
import '../../utils/mime_types.dart';
import '../../widgets/buttons.dart';
import '../../widgets/key_value_text.dart';
import '../../widgets/simple_card.dart';
import '../../widgets/text_field_dialog.dart';
import 'file_explorer_page.dart';

class FileExplorerCard extends StatefulWidget {
  const FileExplorerCard({
    Key? key,
    required this.documentFile,
    required this.didUpdateDocument,
  }) : super(key: key);

  final DocumentFile documentFile;
  final void Function(DocumentFile?) didUpdateDocument;

  @override
  _FileExplorerCardState createState() => _FileExplorerCardState();
}

class _FileExplorerCardState extends State<FileExplorerCard> {
  DocumentFile get _file => widget.documentFile;

  static const _expandedThumbnailSize = Size.square(150);

  Uint8List? _thumbnailImageBytes;
  Size? _thumbnailSize;

  int get _sizeInBytes => _file.size ?? 0;

  bool _expanded = false;
  String? get _displayName => _file.name;

  Future<void> _loadThumbnailIfAvailable() async {
    final uri = _file.uri;

    final bitmap = await getDocumentThumbnail(
      uri: uri,
      width: _expandedThumbnailSize.width,
      height: _expandedThumbnailSize.height,
    );

    if (bitmap == null) {
      _thumbnailImageBytes = Uint8List.fromList([]);
      _thumbnailSize = Size.zero;
    } else {
      _thumbnailImageBytes = bitmap.bytes;
      _thumbnailSize = Size(bitmap.width! / 1, bitmap.height! / 1);
    }

    if (mounted) setState(() {});
  }

  StreamSubscription<String>? _subscription;

  Future<bool> Function() _fileConfirmation(
    String action,
    VoidCallback callback,
  ) {
    return confirm(
      context,
      action,
      callback,
      message: [
        normal('You are '),
        bold('writing'),
        normal(' to this file and it is '),
        bold('not a reversible action'),
        normal('. It can '),
        bold(red('corrupt the file')),
        normal(' or '),
        bold(red('cause data loss')),
        normal(', '),
        italic('be cautious'),
        normal('.'),
      ],
    );
  }

  VoidCallback _directoryConfirmation(String action, VoidCallback callback) {
    return confirm(
      context,
      action,
      callback,
      message: [
        normal('You are '),
        bold('deleting'),
        normal(' this folder, this is '),
        bold('not reversible'),
        normal(' and '),
        bold(red('can cause data loss ')),
        normal('or even'),
        bold(red(' corrupt some apps')),
        normal(' depending on which folder you are deleting, '),
        italic('be cautious.'),
      ],
    );
  }

  Widget _buildMimeTypeIconThumbnail(String mimeType, {double? size}) {
    if (_isDirectory) {
      return Icon(Icons.folder, size: size, color: Colors.blueGrey);
    }

    if (mimeType == kApkMime) {
      return Icon(Icons.android, color: const Color(0xff3AD17D), size: size);
    }

    if (mimeType == kTextPlainMime) {
      return Icon(Icons.description, size: size, color: Colors.blue);
    }

    if (mimeType.startsWith(kVideoMime)) {
      return Icon(Icons.movie, size: size, color: Colors.deepOrange);
    }

    return Icon(
      Icons.browser_not_supported_outlined,
      size: size,
      color: disabledColor(),
    );
  }

  @override
  void initState() {
    super.initState();

    _loadThumbnailIfAvailable();
  }

  @override
  void didUpdateWidget(covariant FileExplorerCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.documentFile.id != widget.documentFile.id) {
      _loadThumbnailIfAvailable();
      if (mounted) setState(() => _expanded = false);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _openFolderFileListPage(Uri uri) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FileExplorerPage(uri: uri),
      ),
    );
  }

  Uint8List? content;

  bool get _isDirectory => _file.isDirectory == true;

  int _generateLuckNumber() {
    final random = Random();

    return random.nextInt(1000);
  }

  Widget _buildThumbnail({required double size}) {
    late Widget thumbnail;

    if (_thumbnailImageBytes == null) {
      thumbnail = const CircularProgressIndicator();
    } else if (_thumbnailImageBytes!.isEmpty) {
      thumbnail = _buildMimeTypeIconThumbnail(
        _mimeTypeOrEmpty,
        size: size,
      );
    } else {
      thumbnail = Image.memory(
        _thumbnailImageBytes!,
        fit: BoxFit.contain,
      );

      if (!_expanded) {
        final width = _thumbnailSize?.width;
        final height = _thumbnailSize?.height;

        final aspectRatio =
            width != null && height != null ? width / height : 1.0;

        thumbnail = AspectRatio(
          aspectRatio: aspectRatio,
          child: thumbnail,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: _expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Align(
            alignment: _expanded ? Alignment.centerLeft : Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: size, maxWidth: size),
              child: thumbnail,
            ),
          ),
          if (_expanded) _buildExpandButton(),
        ],
      ),
    );
  }

  Widget _buildExpandButton() {
    return IconButton(
      onPressed: () => setState(() => _expanded = !_expanded),
      icon: _expanded
          ? const Icon(Icons.expand_less, color: Colors.grey)
          : const Icon(Icons.expand_more, color: Colors.grey),
    );
  }

  Uri get _currentUri => widget.documentFile.uri;

  Widget _buildNotAvailableText() {
    return Text('Not available', style: disabledTextStyle());
  }

  Widget _buildOpenWithButton() =>
      Button('Open with', onTap: _currentUri.openWithExternalApp);

  Widget _buildDocumentSimplifiedTile() {
    return ListTile(
      dense: true,
      leading: _buildThumbnail(size: 25),
      title: Text(
        '$_displayName',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(formatBytes(_sizeInBytes, 2)),
      trailing: _buildExpandButton(),
    );
  }

  Widget _buildDocumentMetadata() {
    return KeyValueText(
      entries: {
        'name': '$_displayName',
        'type': '${_file.type}',
        'isVirtual': '${_file.isVirtual}',
        'isDirectory': '${_file.isDirectory}',
        'isFile': '${_file.isFile}',
        'size': '${formatBytes(_sizeInBytes, 2)} ($_sizeInBytes bytes)',
        'lastModified': '${(() {
          if (_file.lastModified == null) {
            return null;
          }

          return _file.lastModified!.toIso8601String();
        })()}',
        'id': '${_file.id}',
        'parentUri': _file.parentUri?.apply((u) => Uri.decodeFull('$u')) ??
            _buildNotAvailableText(),
        'uri': Uri.decodeFull('${_file.uri}'),
      },
    );
  }

  Widget _buildAvailableActions() {
    return Wrap(
      children: [
        if (_isDirectory)
          ActionButton(
            'Open Directory',
            onTap: _openDirectory,
          ),
        _buildOpenWithButton(),
        DangerButton(
          'Delete ${_isDirectory ? 'Directory' : 'File'}',
          onTap: _isDirectory
              ? _directoryConfirmation('Delete', _deleteDocument)
              : _fileConfirmation('Delete', _deleteDocument),
        ),
        if (!_isDirectory) ...[
          DangerButton(
            'Write to File',
            onTap: _fileConfirmation('Overwite', _overwriteFileContents),
          ),
          DangerButton(
            'Append to file',
            onTap: _fileConfirmation('Append', _appendFileContents),
          ),
          DangerButton(
            'Erase file content',
            onTap: _fileConfirmation('Erase', _eraseFileContents),
          ),
          DangerButton(
            'Edit file contents',
            onTap: _editFileContents,
          ),
        ],
      ],
    );
  }

  String get _mimeTypeOrEmpty => _file.type ?? '';

  Future<void> _deleteDocument() async {
    final deleted = await delete(_currentUri);

    if (deleted ?? false) {
      widget.didUpdateDocument(null);
    }
  }

  Future<void> _overwriteFileContents() async {
    await writeToFile(
      _currentUri,
      content: 'Hello World! Your luck number is: ${_generateLuckNumber()}',
      mode: FileMode.write,
    );
  }

  Future<void> _appendFileContents() async {
    final contents = await getDocumentContentAsString(
      _currentUri,
    );

    final prependWithNewLine = contents?.isNotEmpty ?? true;

    await writeToFile(
      _currentUri,
      content:
          "${prependWithNewLine ? '\n' : ''}You file got bigger! Here's your luck number: ${_generateLuckNumber()}",
      mode: FileMode.append,
    );
  }

  Future<void> _eraseFileContents() async {
    await writeToFile(
      _currentUri,
      content: '',
      mode: FileMode.write,
    );
  }

  Future<void> _editFileContents() async {
    final content = await showDialog<String>(
      context: context,
      builder: (context) {
        return const TextFieldDialog(
          labelText: 'New file content:',
          hintText: 'Writing to this file',
          actionText: 'Edit',
        );
      },
    );

    if (content != null) {
      _fileConfirmation(
        'Overwrite',
        () => writeToFileAsString(
          _currentUri,
          content: content,
          mode: FileMode.write,
        ),
      )();
    }
  }

  Future<void> _openDirectory() async {
    if (_isDirectory) {
      _openFolderFileListPage(_file.uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCard(
      onTap: _isDirectory ? _openDirectory : () => _file.showContents(context),
      children: [
        if (_expanded) ...[
          _buildThumbnail(size: 50),
          _buildDocumentMetadata(),
          _buildAvailableActions()
        ] else
          _buildDocumentSimplifiedTile(),
      ],
    );
  }
}
