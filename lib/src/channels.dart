import 'package:flutter/services.dart';

const kRootChannel = 'io.lakscastro.plugins/sharedstorage';

/// `MethodChannels` of this plugin. Flutter use this to communicate with native Android

/// Target [DocumentFile] from `SAF` Android API (New Android APIs use it)
const kDocumentFileChannel = MethodChannel('$kRootChannel/documentfile');

/// `EventChannels` of this plugin. Flutter use this to communicate with native Android

/// Target [DocumentFile] from `SAF` Android API (New Android APIs use it)
const kDocumentFileEventChannel =
    EventChannel('$kRootChannel/event/documentfile');
