import 'package:flutter/material.dart';
import 'package:shared_storage/shared_storage.dart';
import 'key_value_text.dart';
import 'list_files.dart';
import 'simple_card.dart';

class PersistedUriCard extends StatefulWidget {
  const PersistedUriCard({
    Key? key,
    required this.permissionUri,
    required this.onChange,
  }) : super(key: key);

  final UriPermission permissionUri;
  final VoidCallback onChange;

  @override
  _PersistedUriCardState createState() => _PersistedUriCardState();
}

class _PersistedUriCardState extends State<PersistedUriCard> {
  Future<void> _appendSampleFile(Uri parentUri) async {
    /// Create a new file inside the `parentUri`
    final documentFile = await parentUri.toDocumentFile();

    documentFile?.createFileAsString(
      mimeType: 'text/plain',
      content: 'Sample File Content',
      displayName: 'File created by Shared Storage Sample App',
    );
  }

  Future<void> _revokeUri(Uri uri) async {
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

  Widget _buildActionButton(
    String text, {
    required VoidCallback onTap,
    Color? color,
  }) {
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
