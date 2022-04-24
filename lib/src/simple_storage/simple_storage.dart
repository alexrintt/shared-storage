import '../../saf.dart';
import '../saf/common.dart';
import 'document_file_type.dart';

/// API in development...
Future<DocumentFile?> fromFullPath({
  required String fullPath,
  required DocumentFileType documentFileType,
  bool requiresWriteAccess = false,
  bool considerRawFile = true,
}) {
  const kFromFullPath = 'fromFullPath';

  final args = <String, dynamic>{
    'fullPath': fullPath,
    'documentType': documentFileType.name.toUpperCase(),
    'requiresWriteAccess': requiresWriteAccess,
    'considerRawFile': considerRawFile,
  };

  return invokeMapMethod(kFromFullPath, args);
}
