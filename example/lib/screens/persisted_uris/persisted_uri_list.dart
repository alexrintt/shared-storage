import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_storage/saf.dart';

import '../../theme/spacing.dart';
import '../../widgets/light_text.dart';
import 'persisted_uri_card.dart';

class PersistedUriList extends StatefulWidget {
  const PersistedUriList({Key? key}) : super(key: key);

  @override
  _PersistedUriListState createState() => _PersistedUriListState();
}

class _PersistedUriListState extends State<PersistedUriList> {
  List<UriPermission>? persistedPermissionUris;

  @override
  void initState() {
    super.initState();

    _loadPersistedUriPermissions();
  }

  Future<void> _loadPersistedUriPermissions() async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      persistedPermissionUris = await persistedUriPermissions();

      setState(() => {});
    }
  }

  /// Prompt user with a folder picker (Available for Android 5.0+)
  Future<void> _openDocumentTree() async {
    /// Sample initial directory (WhatsApp status directory)
    const kWppStatusFolder =
        'content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia/document/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2F.Statuses';

    /// If the folder don't exist, the OS will ignore the initial directory
    await openDocumentTree(initialUri: Uri.parse(kWppStatusFolder));

    /// TODO: Add broadcast listener to be aware when a Uri permission changes
    await _loadPersistedUriPermissions();
  }

  Widget _buildNoFolderAllowedYetWarning() {
    return Padding(
      padding: k8dp.all,
      child: const Center(
        child: LightText('No folders allowed yet'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Storage Sample'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPersistedUriPermissions,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: k6dp.all,
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Center(
                      child: TextButton(
                        onPressed: _openDocumentTree,
                        child: const Text('New allowed folder'),
                      ),
                    ),
                    if (persistedPermissionUris != null)
                      if (persistedPermissionUris!.isEmpty)
                        _buildNoFolderAllowedYetWarning()
                      else
                        for (final permissionUri in persistedPermissionUris!)
                          PersistedUriCard(
                            permissionUri: permissionUri,
                            onChange: _loadPersistedUriPermissions,
                          )
                    else
                      const Text('Loading...'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
