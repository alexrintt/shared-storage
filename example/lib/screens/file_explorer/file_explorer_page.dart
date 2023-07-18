import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared_storage/shared_storage.dart';

import '../../theme/spacing.dart';
import '../../widgets/buttons.dart';
import '../../widgets/light_text.dart';
import '../../widgets/simple_card.dart';
import '../../widgets/text_field_dialog.dart';
import 'file_explorer_card.dart';

class FileExplorerPage extends StatefulWidget {
  const FileExplorerPage({
    super.key,
    required this.uri,
  });

  final Uri uri;

  @override
  _FileExplorerPageState createState() => _FileExplorerPageState();
}

class _FileExplorerPageState extends State<FileExplorerPage> {
  List<ScopedFileSystemEntity>? _files;

  late bool _hasPermission;

  ScopedDirectory? _directory;

  StreamSubscription<ScopedFileSystemEntity>? _listener;

  Future<void> _grantAccess() async {
    await SharedStorage.pickDirectory(initialUri: widget.uri);

    _files = null;

    _loadFiles();
  }

  Widget _buildNoPermissionWarning() {
    return SliverPadding(
      padding: k6dp.eb,
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            SimpleCard(
              onTap: () => {},
              children: [
                Center(
                  child: LightText(
                    'No permission granted to this folder\n\n${widget.uri}\n',
                  ),
                ),
                Center(
                  child: ActionButton(
                    'Grant Access',
                    onTap: _grantAccess,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCustomDocument() async {
    if (_directory == null) return;

    final filename = await showDialog<String>(
      context: context,
      builder: (context) => const TextFieldDialog(
        hintText: 'File name:',
        labelText: 'My Text File',
        suffixText: '.txt',
        actionText: 'Create',
      ),
    );

    if (filename == null) return;

    final createdFile = await _directory!.createChildFile(
      mimeType: 'text/plain',
      displayName: filename,
    );

    _files?.add(createdFile);

    if (mounted) setState(() {});
  }

  Widget _buildCreateDocumentButton() {
    return SliverPadding(
      padding: k6dp.eb,
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            Center(
              child: ActionButton(
                'Create a custom document',
                onTap: _createCustomDocument,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _didUpdateDocument(
    ScopedFileSystemEntity before,
    ScopedFileSystemEntity? after,
  ) {
    if (_files == null) return;

    if (after == null) {
      _files!.removeWhere((doc) => doc.id == before.id);
    } else {
      final indexToUpdate = _files!.indexWhere((doc) => doc.id == before.id);
      _files![indexToUpdate] = after;
    }

    if (mounted) setState(() {});
  }

  Widget _buildDocumentList() {
    return SliverPadding(
      padding: k6dp.et,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final file = _files![index];

            return FileExplorerCard(
              scopedFileSystemEntity: file,
              didUpdateDocument: (document) =>
                  _didUpdateDocument(file, document),
            );
          },
          childCount: _files!.length,
        ),
      ),
    );
  }

  Widget _buildEmptyFolderWarning() {
    return SliverPadding(
      padding: k6dp.eb,
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            SimpleCard(
              onTap: () => {},
              children: const [
                Center(
                  child: LightText(
                    'Empty folder',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList() {
    return CustomScrollView(
      slivers: [
        if (!_hasPermission)
          _buildNoPermissionWarning()
        else ...[
          _buildCreateDocumentButton(),
          if (_files!.isNotEmpty)
            _buildDocumentList()
          else
            _buildEmptyFolderWarning(),
        ]
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    _loadFiles();
  }

  @override
  void dispose() {
    _listener?.cancel();

    super.dispose();
  }

  Future<void> _loadFiles() async {
    final directory = await ScopedDirectory.fromUri(widget.uri);

    _hasPermission = await directory.canRead();

    if (!_hasPermission) {
      return setState(() => _files = []);
    }

    final fileListStream = directory.list();

    _listener = fileListStream.listen(
      (file) {
        /// Append new files to the current file list
        _files = [...?_files, file];

        /// Update the state only if the widget is currently showing
        if (mounted) {
          setState(() {});
        } else {
          _listener?.cancel();
        }
      },
      onDone: () => setState(() => _files = [...?_files]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inside ${widget.uri.pathSegments.last}')),
      body: _files == null
          ? const Center(child: CircularProgressIndicator())
          : _buildFileList(),
    );
  }
}
