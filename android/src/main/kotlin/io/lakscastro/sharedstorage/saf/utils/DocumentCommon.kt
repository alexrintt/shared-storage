package io.lakscastro.sharedstorage.saf.utils

import android.content.ContentResolver
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import androidx.annotation.RequiresApi
import androidx.documentfile.provider.DocumentFile
import java.io.Closeable

/// Generate the `DocumentFile` reference from string `uri`
fun documentFromTreeUri(context: Context, uri: String): DocumentFile? =
  documentFromTreeUri(context, Uri.parse(uri))

/// Generate the `DocumentFile` reference from URI `uri`
fun documentFromTreeUri(context: Context, uri: Uri): DocumentFile? =
  DocumentFile.fromTreeUri(context, uri)

/// Standard map encoding of a `DocumentFile` and must be used before returning any `DocumentFile`
/// from plugin results, like:
/// ```dart
/// result.success(createDocumentFileMap(documentFile))
/// ```
fun createDocumentFileMap(documentFile: DocumentFile?): Map<String, Any?>? {
  if (documentFile == null) return null

  return mapOf(
    "isDirectory" to documentFile.isDirectory,
    "isFile" to documentFile.isFile,
    "isVirtual" to documentFile.isVirtual,
    "name" to (documentFile.name ?: ""),
    "type" to (documentFile.type ?: ""),
    "uri" to "${documentFile.uri}",
    "exists" to "${documentFile.exists()}"
  )
}

/// Standard map encoding of a row result of a `DocumentFile`
/// ```dart
/// result.success(createDocumentFileMap(documentFile))
/// ```
/// Example:
/// ```py
/// input = {
///   "last_modified": 2939496, /// Key from DocumentsContract.Document.COLUMN_LAST_MODIFIED
///   "_display_name": "MyFile" /// Key from DocumentsContract.Document.COLUMN_DISPLAY_NAME
/// }
///
/// output = createCursorRowMap(input)
///
/// print(output)
/// {
///   "lastModified": 2939496,
///   "displayName": "MyFile"
/// }
/// ```
@RequiresApi(Build.VERSION_CODES.KITKAT)
fun createCursorRowMap(rootUri: Uri, parentUri: Uri, data: Map<String, Any>?): Map<String, Any>? {
  if (data == null) return null

  val values = DocumentFileColumn.values()

  val formattedData = mutableMapOf<String, Any>()

  for (value in values) {
    val key = parseDocumentFileColumn(value)!!

    if (data[key] != null) {
      formattedData[documentFileColumnToRawString(value)!!] = data[key]!!
    }
  }

  return mapOf(
    "data" to formattedData,
    "metadata" to mapOf(
      "parentUri" to "$parentUri",
      "rootUri" to "$rootUri"
    )
  )
}

/// Util method to close a closeable
fun closeQuietly(closeable: Closeable?) {
  if (closeable != null) {
    try {
      closeable.close()
    } catch (e: RuntimeException) {
      throw e
    } catch (ignore: Exception) {
    }
  }
}

@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
fun traverseDirectoryEntries(
  contentResolver: ContentResolver,
  rootUri: Uri,
  columns: Array<String>,
  rootOnly: Boolean,
  block: (data: Map<String, Any>) -> Unit
) {
  val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
    rootUri,
    DocumentsContract.getTreeDocumentId(rootUri)
  )

  // Keep track of our directory hierarchy
  val dirNodes = mutableListOf<Pair<Uri, Uri>>(Pair(rootUri, childrenUri))

  while (dirNodes.isNotEmpty()) {
    val (parent, children) = dirNodes.removeAt(0)

    val requiredColumns = if (rootOnly) emptyArray() else arrayOf(
      DocumentsContract.Document.COLUMN_MIME_TYPE,
      DocumentsContract.Document.COLUMN_DOCUMENT_ID
    )

    val projection = arrayOf(*columns, *requiredColumns).toSet().toTypedArray()

    val cursor = contentResolver.query(
      children,
      projection,
      /// TODO: Add support for `selection`, `selectionArgs` and `sortOrder`
      null,
      null,
      null
    ) ?: return

    try {
      while (cursor.moveToNext()) {
        val data = mutableMapOf<String, Any>()

        for (column in columns) {
          data[column] = cursorHandlerOf(typeOfColumn(column)!!)(
            cursor,
            cursor.getColumnIndexOrThrow(column)
          )
        }

        block(createCursorRowMap(rootUri, parent, data)!!)

        val mimeType = data[DocumentsContract.Document.COLUMN_MIME_TYPE] as String?
        val id = data[DocumentsContract.Document.COLUMN_DOCUMENT_ID] as String as String?

        if (!rootOnly) {
          if (isDirectory(mimeType)) {
            val nextChildren = DocumentsContract.buildChildDocumentsUriUsingTree(rootUri, id)
            val nextParent = DocumentsContract.buildDocumentUri(rootUri.authority, id)
            val nextNode = Pair(nextParent, nextChildren)

            dirNodes.add(nextNode)
          }
        }
      }
    } finally {
      closeQuietly(cursor)
    }
  }
}

@RequiresApi(Build.VERSION_CODES.KITKAT)
private fun isDirectory(mimeType: String?): Boolean {
  return DocumentsContract.Document.MIME_TYPE_DIR == mimeType
}