import 'package:flutter/material.dart';

class SimpleCard extends StatefulWidget {
  const SimpleCard({Key? key, required this.onTap, required this.children})
      : super(key: key);

  final VoidCallback onTap;
  final List<Widget> children;

  @override
  _SimpleCardState createState() => _SimpleCardState();
}

class _SimpleCardState extends State<SimpleCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.children,
          ),
        ),
      ),
    );
  }
}
