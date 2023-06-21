int currentMicrosecondsSinceEpoch() {
  final DateTime now = DateTime.now();
  return now.microsecondsSinceEpoch;
}

String generateTimeBasedId() => currentMicrosecondsSinceEpoch().toString();
