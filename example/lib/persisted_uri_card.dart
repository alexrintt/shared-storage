import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_storage/shared_storage.dart';

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
    /// Create a new file inside the folder [parentUri]
    await createDocumentFile(
      mimeType: 'text/plain',
      content: 'Sample File Content',
      displayName: 'File created by Shared Storage Sample App',
      directory: parentUri,
    );
  }

  TextSpan _buildTextSpan(String key, String value) {
    return TextSpan(
      children: [
        TextSpan(
          text: '$key: ',
        ),
        TextSpan(
          text: '$value\n',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  void _revokeUri(Uri uri) async {
    await releasePersistableUriPermission(uri);

    widget.onChange();
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  _buildTextSpan(
                    'isWritePermission',
                    '${widget.permissionUri.isWritePermission}',
                  ),
                  _buildTextSpan(
                    'isReadPermission',
                    '${widget.permissionUri.isReadPermission}',
                  ),
                  _buildTextSpan(
                    'persistedTime',
                    '${widget.permissionUri.persistedTime}',
                  ),
                  _buildTextSpan(
                    'uri',
                    '${widget.permissionUri.uri}',
                  ),
                ],
              ),
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
        ),
      ),
    );
  }
}
