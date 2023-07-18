import 'package:flutter/material.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:shared_storage/shared_storage.dart';

import '../../theme/spacing.dart';
import '../../utils/disabled_text_style.dart';
import '../../widgets/light_text.dart';
import '../file_explorer/file_explorer_card.dart';
import 'granted_uri_card.dart';

class GrantedUrisPage extends StatefulWidget {
  const GrantedUrisPage({super.key});

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
    _loadInitialIntents();
  }

  Future<void> _loadInitialIntents() async {
    final receivedIntent = await ReceiveIntent.getInitialIntent();

    List<Uri> getMultiSendUris() {
      try {
        final List<String> receivedUris = List<String>.from(
          receivedIntent?.extra?['android.intent.extra.STREAM']
              as Iterable<dynamic>,
        );

        return receivedUris.map(Uri.parse).whereType<Uri>().toList();
      } catch (e) {
        return <Uri>[];
      }
    }

    List<Uri> getSingleSendUri() {
      final dynamic receivedUri =
          receivedIntent?.extra?['android.intent.extra.STREAM'];

      if (receivedUri is! String) {
        return <Uri>[];
      }

      return <Uri?>[Uri.tryParse(receivedUri)].whereType<Uri>().toList();
    }

    final List<Uri> uris = [];

    switch (receivedIntent?.action) {
      case 'android.intent.action.SEND_MULTIPLE':
        uris.addAll(getMultiSendUris());
        break;
      case 'android.intent.action.SEND':
        uris.addAll(getSingleSendUri());
        break;
    }

    // for (final uri in uris) {
    //   int bytes = 0;
    //   getDocumentContentAsStream(uri).listen(
    //     (event) {
    //       bytes += event.length;
    //     },
    //     onDone: () => print('Done, loaded $bytes'),
    //   );
    // }

    // return;

    final files = <ScopedFile?>[
      for (final uri in uris) await SharedStorage.buildScopedFileFromUri(uri)
    ].whereType<ScopedFile>().toList();

    if (files.isNotEmpty) {
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Received files'),
              content: ReceivedUrisByIntentList(files: files),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
      }
    }
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
    await SharedStorage.pickDirectory(initialUri: Uri.parse(kWppStatusFolder));

    /// TODO: Add broadcast listener to be aware when a Uri permission changes
    await _loadPersistedUriPermissions();
  }

  Future<void> _openDocument() async {
    const kDownloadsFolder =
        'content://com.android.externalstorage.documents/tree/primary%3ADownloads/document/primary%3ADownloads';

    await SharedStorage.pickFiles(initialUri: Uri.parse(kDownloadsFolder));

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

class ReceivedUrisByIntentList extends StatefulWidget {
  const ReceivedUrisByIntentList({super.key, required this.files});

  final List<ScopedFile> files;

  @override
  State<ReceivedUrisByIntentList> createState() =>
      _ReceivedUrisByIntentListState();
}

class _ReceivedUrisByIntentListState extends State<ReceivedUrisByIntentList> {
  final Map<String, ScopedFileSystemEntity> _updated = {};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            for (final fileSystemEntity in widget.files)
              FileExplorerCard(
                allowExpand: false,
                scopedFileSystemEntity:
                    _updated[fileSystemEntity.id] ?? fileSystemEntity,
                didUpdateDocument: (updated) {
                  // Ignore, we do not allow the card to expand thus not allow to update.
                },
              ),
          ],
        ),
      ),
    );
  }
}
