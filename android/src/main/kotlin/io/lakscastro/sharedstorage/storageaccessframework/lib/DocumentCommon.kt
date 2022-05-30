package io.lakscastro.sharedstorage.storageaccessframework.lib

import android.content.ContentResolver
import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.util.Base64
import androidx.annotation.RequiresApi
import androidx.documentfile.provider.DocumentFile
import io.lakscastro.sharedstorage.plugin.API_19
import io.lakscastro.sharedstorage.plugin.API_21
import io.lakscastro.sharedstorage.plugin.API_24
import java.io.ByteArrayOutputStream
import java.io.Closeable

/**
 * Helper class to make more easy to handle callbacks using Kotlin syntax
 */
data class CallbackHandler<T>(
  var onSuccess: (T.() -> Unit)? = null,
  var onEnd: (() -> Unit)? = null
)

/**
 * Generate the `DocumentFile` reference from string `uri` (Single `DocumentFile`)
 */
@RequiresApi(API_21)
fun documentFromSingleUri(context: Context, uri: String): DocumentFile? =
  documentFromSingleUri(context, Uri.parse(uri))

/**
 * Generate the `DocumentFile` reference from string `uri` (Single `DocumentFile`)
 */
@RequiresApi(API_21)
fun documentFromSingleUri(context: Context, uri: Uri): DocumentFile? {
  val documentUri = DocumentsContract.buildDocumentUri(
    uri.authority,
    DocumentsContract.getDocumentId(uri)
  )

  return DocumentFile.fromSingleUri(context, documentUri)
}

/**
 * Generate the `DocumentFile` reference from string `uri`
 */
@RequiresApi(API_21)
fun documentFromUri(context: Context, uri: String): DocumentFile? =
  documentFromUri(context, Uri.parse(uri))

/**
 * Generate the `DocumentFile` reference from URI `uri`
 */
@RequiresApi(API_21)
fun documentFromUri(
  context: Context,
  uri: Uri
): DocumentFile? {
  return if (isTreeUri(uri)) {
    DocumentFile.fromTreeUri(context, uri)
  } else {
    DocumentFile.fromSingleUri(context, uri)
  }
}

/**
 * Standard map encoding of a `DocumentFile` and must be used before returning any `DocumentFile`
 * from plugin results, like:
 * ```dart
 * result.success(createDocumentFileMap(documentFile))
 * ```
 */
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


/**
 * Standard map encoding of a row result of a `DocumentFile`
 * ```kt
 * result.success(createDocumentFileMap(documentFile))
 * ```
 *
 * Example:
 * ```py
 * input = {
 *   "last_modified": 2939496, # Key from DocumentsContract.Document.COLUMN_LAST_MODIFIED
 *   "_display_name": "MyFile" # Key from DocumentsContract.Document.COLUMN_DISPLAY_NAME
 * }
 *
 * output = createCursorRowMap(input)
 *
 * print(output)
 * {
 *   "lastModified": 2939496,
 *   "displayName": "MyFile"
 * }
 * ```
 */
fun createCursorRowMap(
  rootUri: Uri,
  parentUri: Uri,
  uri: Uri,
  data: Map<String, Any>,
  isDirectory: Boolean?
): Map<String, Any> {
  val values = DocumentFileColumn.values()

  val formattedData = mutableMapOf<String, Any>()

  for (value in values) {
    val key = parseDocumentFileColumn(value)

    if (data[key] != null) {
      formattedData[documentFileColumnToRawString(value)!!] = data[key]!!
    }
  }

  return mapOf(
    "data" to formattedData,
    "metadata" to mapOf(
      "parentUri" to "$parentUri",
      "rootUri" to "$rootUri",
      "isDirectory" to isDirectory,
      "uri" to "$uri"
    )
  )
}

/**
 * Util method to close a closeable
 */
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

@RequiresApi(API_21)
fun traverseDirectoryEntries(
  contentResolver: ContentResolver,
  rootUri: Uri,
  columns: Array<String>,
  rootOnly: Boolean,
  block: (data: Map<String, Any>, isLast: Boolean) -> Unit
): Boolean {
  val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
    rootUri,
    DocumentsContract.getTreeDocumentId(rootUri)
  )

  /// Keep track of our directory hierarchy
  val dirNodes = mutableListOf<Pair<Uri, Uri>>(Pair(rootUri, childrenUri))

  while (dirNodes.isNotEmpty()) {
    val (parent, children) = dirNodes.removeAt(0)

    val requiredColumns =
      if (rootOnly) emptyArray() else arrayOf(DocumentsContract.Document.COLUMN_MIME_TYPE)

    val intrinsicColumns =
      arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID)

    val projection = arrayOf(
      *columns,
      *requiredColumns,
      *intrinsicColumns
    ).toSet().toTypedArray()

    val cursor = contentResolver.query(
      children,
      projection,
      /// TODO: Add support for `selection`, `selectionArgs` and `sortOrder`
      null,
      null,
      null
    ) ?: return false

    try {
      if (cursor.count == 0) {
        return false
      }

      while (cursor.moveToNext()) {
        val data = mutableMapOf<String, Any>()

        for (column in columns) {
          data[column] = cursorHandlerOf(typeOfColumn(column)!!)(
            cursor,
            cursor.getColumnIndexOrThrow(column)
          )
        }

        val mimeType =
          data[DocumentsContract.Document.COLUMN_MIME_TYPE] as String?

        val id =
          data[DocumentsContract.Document.COLUMN_DOCUMENT_ID] as String

        val isDirectory = if (mimeType != null) isDirectory(mimeType) else null

        val uri = DocumentsContract.buildDocumentUriUsingTree(
          parent,
          DocumentsContract.getDocumentId(
            DocumentsContract.buildDocumentUri(parent.authority, id)
          )
        )

        if (isDirectory == true && !rootOnly) {
          val nextChildren =
            DocumentsContract.buildChildDocumentsUriUsingTree(rootUri, id)

          val nextNode = Pair(uri, nextChildren)

          dirNodes.add(nextNode)
        }

        block(
          createCursorRowMap(
            rootUri,
            parent,
            uri,
            data,
            isDirectory = isDirectory
          ),
          dirNodes.isEmpty() && cursor.isLast
        )
      }
    } finally {
      closeQuietly(cursor)
    }
  }

  return true
}

@RequiresApi(API_19)
private fun isDirectory(mimeType: String): Boolean {
  return DocumentsContract.Document.MIME_TYPE_DIR == mimeType
}

fun bitmapToBase64(bitmap: Bitmap): String {
  val outputStream = ByteArrayOutputStream()

  val fullQuality = 100

  bitmap.compress(Bitmap.CompressFormat.PNG, fullQuality, outputStream)

  return Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)
}

/**
 * Trick to verify if is a tree URi even not in API 26+
 */
fun isTreeUri(uri: Uri): Boolean {
  if (Build.VERSION.SDK_INT >= API_24) {
    return DocumentsContract.isTreeUri(uri)
  }

  val paths = uri.pathSegments

  return paths.size >= 2 && "tree" == paths[0]
}
