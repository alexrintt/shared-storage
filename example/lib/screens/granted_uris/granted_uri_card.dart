import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:shared_storage/shared_storage.dart';

import '../../theme/spacing.dart';
import '../../utils/disabled_text_style.dart';
import '../../utils/document_file_utils.dart';
import '../../widgets/buttons.dart';
import '../../widgets/key_value_text.dart';
import '../../widgets/simple_card.dart';
import '../file_explorer/file_explorer_card.dart';
import '../file_explorer/file_explorer_page.dart';

class GrantedUriCard extends StatefulWidget {
  const GrantedUriCard({
    Key? key,
    required this.permissionUri,
    required this.onChange,
  }) : super(key: key);

  final UriPermission permissionUri;
  final VoidCallback onChange;

  @override
  _GrantedUriCardState createState() => _GrantedUriCardState();
}

class _GrantedUriCardState extends State<GrantedUriCard> {
  Future<void> _appendSampleFile(Uri parentUri) async {
    /// Create a new file inside the `parentUri`
    final documentFile = await parentUri.toDocumentFile();

    const kFilename = 'Sample File';

    final child = await documentFile?.child(kFilename);

    if (child == null) {
      documentFile?.createFileAsString(
        mimeType: 'text/plain',
        content: 'Sample File Content',
        displayName: kFilename,
      );
    } else {
      print('This File Already Exists');
    }
  }

  Future<void> _revokeUri(Uri uri) async {
    await releasePersistableUriPermission(uri);

    widget.onChange();
  }

  void _openListFilesPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FileExplorerPage(uri: widget.permissionUri.uri),
      ),
    );
  }

  List<Widget> _getTreeAvailableOptions() {
    return [
      ActionButton(
        'Create sample file',
        onTap: () => _appendSampleFile(
          widget.permissionUri.uri,
        ),
      ),
      ActionButton(
        'Open tree here',
        onTap: () => openDocumentTree(initialUri: widget.permissionUri.uri),
      )
    ];
  }

  DocumentFile? documentFile;
  bool loading = false;
  String? error;

  Future<void> _loadDocumentFile() async {
    loading = true;
    setState(() {});

    documentFile = await widget.permissionUri.uri.toDocumentFile();
    loading = false;

    if (mounted) setState(() {});
  }

  Future<void> _showDocumentFileContents() async {
    try {
      final documentFile = await widget.permissionUri.uri.toDocumentFile();

      if (mounted) documentFile?.showContents(context);
    } catch (e) {
      error = e.toString();
    }
  }

  List<Widget> _getDocumentAvailableOptions() {
    return [
      ActionButton(
        'Open document',
        onTap: _showDocumentFileContents,
      ),
      ActionButton(
        'Load extra document data linked to this permission',
        onTap: _loadDocumentFile,
      ),
    ];
  }

  Widget _buildAvailableActions() {
    return Wrap(
      children: [
        if (widget.permissionUri.isTreeDocumentFile)
          ..._getTreeAvailableOptions()
        else
          ..._getDocumentAvailableOptions(),
        Padding(padding: k2dp.all),
        DangerButton(
          'Revoke',
          onTap: () => _revokeUri(
            widget.permissionUri.uri,
          ),
        ),
      ],
    );
  }

  Widget _buildGrantedUriMetadata() {
    return KeyValueText(
      entries: {
        'isWritePermission': '${widget.permissionUri.isWritePermission}',
        'isReadPermission': '${widget.permissionUri.isReadPermission}',
        'persistedTime': '${widget.permissionUri.persistedTime}',
        'uri': Uri.decodeFull('${widget.permissionUri.uri}'),
        'isTreeDocumentFile': '${widget.permissionUri.isTreeDocumentFile}',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCard(
      onTap: widget.permissionUri.isTreeDocumentFile
          ? _openListFilesPage
          : _showDocumentFileContents,
      children: [
        Padding(
          padding: k2dp.all.copyWith(top: k8dp, bottom: k8dp),
          child: Icon(
            widget.permissionUri.isTreeDocumentFile
                ? Icons.folder
                : Icons.file_copy_sharp,
            color: disabledColor(),
          ),
        ),
        _buildGrantedUriMetadata(),
        _buildAvailableActions(),
        if (loading)
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(),
          )
        else if (error != null)
          Text('Error was thrown: $error')
        else if (documentFile != null)
          FileExplorerCard(
            documentFile: documentFile!,
            didUpdateDocument: (updatedDocumentFile) {
              documentFile = updatedDocumentFile;
            },
          )
      ],
    );
  }
}
