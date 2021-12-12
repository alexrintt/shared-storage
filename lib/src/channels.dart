import 'package:flutter/services.dart';

const kRootChannel = 'io.lakscastro.plugins/sharedstorage';

/// Method Channels of this plugin
///
/// Flutter uses this to communicate with native Android
/// Target [Environment] Android API (Legacy and you should avoid it)
const kEnvironmentChannel = MethodChannel('$kRootChannel/environment');

/// Target [MediaStore] Android API
const kMediaStoreChannel = MethodChannel('$kRootChannel/mediastore');

/// Target [DocumentFile] from `SAF` Android API (New Android API's use it)
const kDocumentFileChannel = MethodChannel('$kRootChannel/documentfile');

/// Event Channels of this plugin
const kDocumentFileEventChannel =
    EventChannel('$kRootChannel/event/documentfile');
