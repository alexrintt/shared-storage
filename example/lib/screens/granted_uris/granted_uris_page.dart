import 'package:flutter/material.dart';
import 'package:shared_storage/shared_storage.dart';

import '../../theme/spacing.dart';
import '../../utils/disabled_text_style.dart';
import '../../widgets/light_text.dart';
import 'granted_uri_card.dart';

class GrantedUrisPage extends StatefulWidget {
  const GrantedUrisPage({Key? key}) : super(key: key);

  @override
  _GrantedUrisPageState createState() => _GrantedUrisPageState();
}

class _GrantedUrisPageState extends State<GrantedUrisPage> {
  List<UriPermission>? __persistedPermissionUris;
  List<UriPermission>? get _persistedPermissionUris {
    if (__persistedPermissionUris == null) return null;

    return List.from(__persistedPermissionUris!)
      ..sort((a, z) => z.persistedTime - a.persistedTime);
  }

  @override
  void initState() {
    super.initState();

    _loadPersistedUriPermissions();
  }

  Future<void> _loadPersistedUriPermissions() async {
    __persistedPermissionUris = await persistedUriPermissions();

    if (mounted) setState(() => {});
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

  Future<void> _openDocument() async {
    const kDownloadsFolder =
        'content://com.android.externalstorage.documents/tree/primary%3ADownloads/document/primary%3ADownloads';

    final List<Uri>? selectedDocumentUris = await openDocument(
      initialUri: Uri.parse(kDownloadsFolder),
      multiple: true,
    );

    if (selectedDocumentUris == null) return;

    await _loadPersistedUriPermissions();
  }

  Widget _buildNoFolderAllowedYetWarning() {
    return Padding(
      padding: k8dp.all,
      child: const Center(
        child: LightText('No folders or files allowed yet'),
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
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runAlignment: WrapAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _openDocumentTree,
                            child: const Text('New allowed folder'),
                          ),
                          const Padding(padding: EdgeInsets.all(k2dp)),
                          TextButton(
                            onPressed: _openDocument,
                            child: const Text('New allowed files'),
                          ),
                        ],
                      ),
                    ),
                    if (_persistedPermissionUris != null)
                      if (_persistedPermissionUris!.isEmpty)
                        _buildNoFolderAllowedYetWarning()
                      else
                        for (final permissionUri in _persistedPermissionUris!)
                          GrantedUriCard(
                            permissionUri: permissionUri,
                            onChange: _loadPersistedUriPermissions,
                          )
                    else
                      Center(
                        child: Text(
                          'Loading...',
                          style: disabledTextStyle(),
                        ),
                      ),
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
