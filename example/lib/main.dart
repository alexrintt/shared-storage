import 'package:flutter/material.dart';
import 'screens/granted_uris/granted_uris_page.dart';

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
    return const MaterialApp(home: GrantedUrisPage());
  }
}
