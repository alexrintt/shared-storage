import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_storage/saf.dart';
import 'light_text.dart';
import 'persisted_uri_card.dart';
import 'spacing.dart';

/// TODO: Add examples using [Environment] and [MediaStore] API
void main() => runApp(const Root());

class Root extends StatefulWidget {
  const Root({Key? key}) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: App());
  }
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
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

  Future<void> _openDocumentTree() async {
    /// Prompt user with a folder picker (Available for Android 5.0+)

    const kWppStatusFolder =
        'content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia/document/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2F.Statuses%2FMedia';

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
