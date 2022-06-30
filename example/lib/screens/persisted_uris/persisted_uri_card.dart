import 'package:flutter/material.dart';
import 'package:shared_storage/saf.dart';

import '../../theme/spacing.dart';
import '../../widgets/buttons.dart';
import '../../widgets/key_value_text.dart';
import '../../widgets/simple_card.dart';
import '../folder_files/folder_file_list.dart';

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
        builder: (context) => FolderFileList(
          uri: widget.permissionUri.uri,

          rootUri: widget.permissionUri
              .uri, // Since the persisted uri is the root uri itself we use the same uri for both: target listing uri and the granted root uri
        ),
      ),
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
        Wrap(
          children: [
            ActionButton(
              'Create Sample File',
              onTap: () => _appendSampleFile(
                widget.permissionUri.uri,
              ),
            ),
            ActionButton(
              'Open Tree Here',
              onTap: () =>
                  openDocumentTree(initialUri: widget.permissionUri.uri),
            ),
            Padding(padding: k2dp.all),
            DangerButton(
              'Revoke',
              onTap: () => _revokeUri(
                widget.permissionUri.uri,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
