import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_storage/saf.dart';

import '../../theme/spacing.dart';
import '../../widgets/buttons.dart';
import '../../widgets/light_text.dart';
import '../../widgets/simple_card.dart';
import 'folder_file_card.dart';

class FolderFileList extends StatefulWidget {
  const FolderFileList({Key? key, required this.uri}) : super(key: key);

  final Uri uri;

  @override
  _FolderFileListState createState() => _FolderFileListState();
}

class _FolderFileListState extends State<FolderFileList> {
  List<PartialDocumentFile>? _files;

  late bool _hasPermission;

  StreamSubscription<PartialDocumentFile>? _listener;

  Future<void> _grantAccess() async {
    final uri = await openDocumentTree(initialUri: widget.uri);

    if (uri == null) return;

    _files = null;

    _loadFiles();
  }

  Widget _buildFileList() {
    return CustomScrollView(
      slivers: [
        if (!_hasPermission)
          SliverPadding(
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
          )
        else ...[
          SliverPadding(
            padding: k6dp.eb,
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Center(
                    child: ActionButton(
                      'Create a custom document',
                      onTap: () => {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_files!.isNotEmpty)
            SliverPadding(
              padding: k6dp.et,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final file = _files![index];

                    return FolderFileCard(
                      partialFile: file,
                      didUpdateDocument: (document) {
                        if (document == null) {
                          _files?.removeWhere(
                            (doc) =>
                                doc.data?[DocumentFileColumn.id] ==
                                file.data?[DocumentFileColumn.id],
                          );

                          if (mounted) setState(() {});
                        }
                      },
                    );
                  },
                  childCount: _files!.length,
                ),
              ),
            )
          else
            SliverPadding(
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
            )
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
    _hasPermission = await canRead(widget.uri) ?? false;

    if (!_hasPermission) {
      return setState(() => _files = []);
    }

    final documentUri = await widget.uri.toDocumentFile();

    const columns = [
      DocumentFileColumn.displayName,
      DocumentFileColumn.size,
      DocumentFileColumn.lastModified,
      DocumentFileColumn.id,
      DocumentFileColumn.mimeType,
    ];

    _listener = documentUri?.listFiles(columns).listen(
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
