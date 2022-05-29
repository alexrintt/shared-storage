import 'package:flutter/cupertino.dart';

class LightText extends StatelessWidget {
  const LightText(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: const Color(0xFF000000).withOpacity(.2),
      ),
    );
  }
}
