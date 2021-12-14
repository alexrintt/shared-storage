import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_storage/shared_storage.dart';
import 'package:shared_storage_example/key_value_text.dart';
import 'package:shared_storage_example/list_files.dart';
import 'package:shared_storage_example/simple_card.dart';

class PersistedUriCard extends StatefulWidget {
  final UriPermission permissionUri;
  final VoidCallback onChange;

  const PersistedUriCard(
      {Key? key, required this.permissionUri, required this.onChange})
      : super(key: key);

  @override
  _PersistedUriCardState createState() => _PersistedUriCardState();
}

class _PersistedUriCardState extends State<PersistedUriCard> {
  void _appendSampleFile(Uri parentUri) async {
    /// Create a new file inside the `parentUri`
    final documentFile = await parentUri.toDocumentFile();

    documentFile?.createFileAsString(
      mimeType: 'text/plain',
      content: 'Sample File Content',
      displayName: 'File created by Shared Storage Sample App',
    );
  }

  void _revokeUri(Uri uri) async {
    await releasePersistableUriPermission(uri);

    widget.onChange();
  }

  void _openListFilesPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ListFiles(uri: widget.permissionUri.uri),
      ),
    );
  }

  Widget _buildActionButton(String text,
      {required VoidCallback onTap, Color? color}) {
    return TextButton(
      style: TextButton.styleFrom(primary: color),
      onPressed: onTap,
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCard(
      onTap: _openListFilesPage,
      children: [
        KeyValueText(
          entries: {
            'isWritePermission': '${widget.permissionUri.isWritePermission}',
            'isReadPermission': '${widget.permissionUri.isReadPermission}',
            'persistedTime': '${widget.permissionUri.persistedTime}',
            'uri': '${widget.permissionUri.uri}',
          },
        ),
        Row(
          children: [
            _buildActionButton(
              'Create Sample File',
              onTap: () => _appendSampleFile(
                widget.permissionUri.uri,
              ),
            ),
            const Padding(padding: EdgeInsets.all(4)),
            _buildActionButton(
              'Revoke',
              onTap: () => _revokeUri(
                widget.permissionUri.uri,
              ),
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}
