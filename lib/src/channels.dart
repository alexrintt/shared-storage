import 'package:flutter/services.dart';

const String kRootChannel = 'io.alexrintt.plugins/sharedstorage';

const MethodChannel kDocumentFileChannel =
    MethodChannel('$kRootChannel/documentfile');

const MethodChannel kDocumentsContractChannel =
    MethodChannel('$kRootChannel/documentscontract');

const MethodChannel kDocumentFileHelperChannel =
    MethodChannel('$kRootChannel/documentfilehelper');

const EventChannel kDocumentFileEventChannel =
    EventChannel('$kRootChannel/event/documentfile');
