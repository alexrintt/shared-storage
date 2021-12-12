import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_storage/shared_storage.dart';
import 'package:shared_storage_example/key_value_text.dart';
import 'package:shared_storage_example/simple_card.dart';

class ListFiles extends StatefulWidget {
  final Uri uri;

  const ListFiles({Key? key, required this.uri}) : super(key: key);

  @override
  _ListFilesState createState() => _ListFilesState();
}

class _ListFilesState extends State<ListFiles> {
  List<Map<DocumentFileColumn, dynamic>>? _files;

  StreamSubscription<Map<DocumentFileColumn, dynamic>>? _listener;

  Widget _buildFileList() {
    if (_files!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("Empty Folder"),
        ),
      );
    }

    return ListView.builder(
      itemCount: _files!.length,
      itemBuilder: (context, index) {
        final file = _files![index];
        return SimpleCard(
          onTap: () {},
          children: [
            KeyValueText(
              entries: {
                'name': '${file[DocumentFileColumn.displayName]}',
                'type': '${file[DocumentFileColumn.mimeType]}',
                'size': '${file[DocumentFileColumn.size]}',
                'lastModified': '${(() {
                  if (file[DocumentFileColumn.lastModified] == null) {
                    return null;
                  }
                  final millisecondsSinceEpoch =
                      file[DocumentFileColumn.lastModified]! ~/ 100;

                  final date = DateTime.fromMillisecondsSinceEpoch(
                    millisecondsSinceEpoch,
                  );

                  return date.toIso8601String();
                })()}',
                'summary': '${file[DocumentFileColumn.summary]}',
                'id': '${file[DocumentFileColumn.id]}',
              },
            ),
          ],
        );
      },
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

  void _loadFiles() async {
    final documentUri = await widget.uri.toDocumentFile();

    final columns = [
      DocumentFileColumn.displayName,
      DocumentFileColumn.size,
      DocumentFileColumn.lastModified,
      DocumentFileColumn.id,
      DocumentFileColumn.mimeType,
    ];

    _listener = documentUri?.listFilesAsStream(columns).listen(
          (file) => setState(
            () => _files == null ? _files = [file] : _files!.add(file),
          ),
        );
    // _files = (await documentUri!.listFiles())!
    //     .map((e) => <DocumentFileColumn, dynamic>{
    //           DocumentFileColumn.displayName: e.name,
    //           DocumentFileColumn.mimeType: e.type
    //         })
    //     .toList();

    setState(() {});
  }

  // void _openListFilesPage(Uri uri) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => ListFiles(uri: uri),
  //     ),
  //   );
  // }

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
