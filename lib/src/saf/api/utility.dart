import '../../channels.dart';
import '../common/barrel.dart';
import '../models/barrel.dart';

/// {@template sharedstorage.saf.fromTreeUri}
/// Create a new `DocumentFile` instance given `uri`.
///
/// Equivalent to `DocumentFile.fromTreeUri`.
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#fromTreeUri%28android.content.Context,%20android.net.Uri%29).
/// {@endtemplate}
Future<DocumentFile?> fromTreeUri(Uri uri) async =>
    invokeMapMethod('fromTreeUri', <String, String>{'uri': '$uri'});

/// {@template sharedstorage.saf.getDocumentContentAsString}
/// Helper method to generate the file path of the given `uri`
///
/// See [Get real path from URI, Android KitKat new storage access framework](https://stackoverflow.com/questions/20067508/get-real-path-from-uri-android-kitkat-new-storage-access-framework/20559175#20559175)
/// for details.
/// {@endtemplate}
Future<String?> getRealPathFromUri(Uri uri) async => kDocumentFileHelperChannel
    .invokeMethod('getRealPathFromUri', <String, String>{'uri': '$uri'});
