package io.alexrintt.sharedstorage.storageaccessframework.lib

import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.provider.DocumentsProvider
import android.util.Base64
import androidx.annotation.RequiresApi
import androidx.documentfile.provider.DocumentFile
import com.anggrayudi.storage.extension.isMediaDocument
import com.anggrayudi.storage.extension.isMediaFile
import com.anggrayudi.storage.file.DocumentFileCompat
import io.alexrintt.sharedstorage.deprecated.lib.cursorHandlerOf
import io.alexrintt.sharedstorage.deprecated.lib.typeOfColumn
import io.alexrintt.sharedstorage.mediastore.ScopedFileSystemEntity
import io.alexrintt.sharedstorage.plugin.*
import io.alexrintt.sharedstorage.storageaccessframework.*
import java.io.ByteArrayOutputStream
import java.io.Closeable

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
fun documentFromUri(context: Context, uri: Uri): DocumentFile? {
  return if (isTreeUri(uri)) {
    DocumentFile.fromTreeUri(context, uri)
  } else {
    DocumentFile.fromSingleUri(context, uri)
  }
}


/**
 * Convert a [DocumentFile] using the default method for map encoding
 */
fun createDocumentFileMap(documentFile: DocumentFile?): Map<String, Any?>? {
  if (documentFile == null) return null

  return createDocumentFileMap(
    DocumentsContract.getDocumentId(documentFile.uri),
    parentUri = documentFile.parentFile?.uri,
    isDirectory = documentFile.isDirectory,
    isFile = documentFile.isFile,
    isVirtual = documentFile.isVirtual,
    name = documentFile.name,
    type = documentFile.type,
    uri = documentFile.uri,
    exists = documentFile.exists(),
    size = documentFile.length(),
    lastModified = documentFile.lastModified()
  )
}

/**
 * Standard map encoding of a `DocumentFile` and must be used before returning any `DocumentFile`
 * from plugin results, like:
 * ```dart
 * result.success(createDocumentFileMap(documentFile))
 * ```
 */
fun createDocumentFileMap(
  id: String?,
  parentUri: Uri?,
  isDirectory: Boolean?,
  isFile: Boolean?,
  isVirtual: Boolean?,
  name: String?,
  type: String?,
  uri: Uri,
  exists: Boolean?,
  size: Long?,
  lastModified: Long?
): Map<String, Any?> {
  return mapOf(
    "id" to id,
    "parentUri" to "$parentUri",
    "isDirectory" to isDirectory,
    "isFile" to isFile,
    "isVirtual" to isVirtual,
    "name" to name,
    "type" to type,
    "uri" to "$uri",
    "exists" to exists,
    "size" to size,
    "lastModified" to lastModified
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

@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
fun traverseMediaDirectoryEntries(
  context: Context,
  targetUri: Uri,
  columns: Array<String>,
  rootOnly: Boolean,
  block: (data: Map<String, Any?>, isLast: Boolean) -> Unit
): Boolean {
  val documentId = try {
    DocumentsContract.getDocumentId(targetUri)
  } catch (e: IllegalArgumentException) {
    DocumentsContract.getTreeDocumentId(targetUri)
  }
  val treeDocumentId = DocumentsContract.getTreeDocumentId(targetUri)

  val rootUri = DocumentsContract.buildTreeDocumentUri(
    targetUri.authority,
    treeDocumentId
  )
  val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
    rootUri,
    documentId
  )

  // Keep track of our directory hierarchy
  val dirNodes = mutableListOf(Pair(targetUri, childrenUri))

  while (dirNodes.isNotEmpty()) {
    val (parent, children) = dirNodes.removeAt(0)

    val requiredColumns =
      if (rootOnly) emptyArray() else arrayOf(DocumentsContract.Document.COLUMN_MIME_TYPE)

    val intrinsicColumns =
      arrayOf(
        DocumentsContract.Document.COLUMN_DOCUMENT_ID,
        DocumentsContract.Document.COLUMN_FLAGS
      )

    val projection = arrayOf(
      *columns,
      *requiredColumns,
      *intrinsicColumns
    ).toSet().toTypedArray()

    val cursor = context.contentResolver.query(
      children,
      projection,
      // TODO: Add support for `selection`, `selectionArgs` and `sortOrder`
      null,
      null,
      null
    ) ?: return false

    try {
      if (cursor.count == 0) {
        return false
      }

      while (cursor.moveToNext()) {
        val data = mutableMapOf<String, Any?>()

        for (column in projection) {
          val columnValue: Any? = cursorHandlerOf(typeOfColumn(column)!!)(
            cursor,
            cursor.getColumnIndexOrThrow(column)
          )

          data[column] = columnValue
        }

        val mimeType =
          data[DocumentsContract.Document.COLUMN_MIME_TYPE] as String?

        val id =
          data[DocumentsContract.Document.COLUMN_DOCUMENT_ID] as String

        val isDirectory = if (mimeType != null) isDirectory(mimeType) else null

        val uri = DocumentsContract.buildDocumentUriUsingTree(
          rootUri,
          DocumentsContract.getDocumentId(
            DocumentsContract.buildDocumentUri(parent.authority, id)
          )
        )

        if (isDirectory == true && !rootOnly) {
          val nextChildren =
            DocumentsContract.buildChildDocumentsUriUsingTree(targetUri, id)

          val nextNode = Pair(uri, nextChildren)

          dirNodes.add(nextNode)
        }

        block(
          ScopedFileSystemEntity(
            parentUri = parent,
            uri = uri,
            displayName = data[DocumentsContract.Document.COLUMN_DISPLAY_NAME] as String,
            id = data[DocumentsContract.Document.COLUMN_DOCUMENT_ID] as String,
            entityType = if (isDirectory == true) "directory" else "file",
            mimeType = data[DocumentsContract.Document.COLUMN_MIME_TYPE] as String,
            length = data[DocumentsContract.Document.COLUMN_SIZE] as Long,
            lastModified = data[DocumentsContract.Document.COLUMN_LAST_MODIFIED] as Long
          ).toMap(),
          dirNodes.isEmpty() && cursor.isLast
        )
      }
    } finally {
      closeQuietly(cursor)
    }
  }

  return true
}

fun isDirectory(mimeType: String): Boolean {
  return mimeType == DocumentsContract.Document.MIME_TYPE_DIR
}

@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
fun traverseSafDirectoryEntries(
  context: Context,
  targetUri: Uri,
  columns: Array<String>,
  rootOnly: Boolean,
  block: (data: Map<String, Any?>, isLast: Boolean) -> Unit
): Boolean {
  val documentId = try {
    DocumentsContract.getDocumentId(targetUri)
  } catch (e: IllegalArgumentException) {
    DocumentsContract.getTreeDocumentId(targetUri)
  }
  val treeDocumentId = DocumentsContract.getTreeDocumentId(targetUri)

  val rootUri = DocumentsContract.buildTreeDocumentUri(
    targetUri.authority,
    treeDocumentId
  )
  val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
    rootUri,
    documentId
  )

  // Keep track of our directory hierarchy
  val dirNodes = mutableListOf(Pair(targetUri, childrenUri))

  while (dirNodes.isNotEmpty()) {
    val (parent, children) = dirNodes.removeAt(0)

    val requiredColumns =
      if (rootOnly) emptyArray() else arrayOf(DocumentsContract.Document.COLUMN_MIME_TYPE)

    val intrinsicColumns =
      arrayOf(
        DocumentsContract.Document.COLUMN_DOCUMENT_ID,
        DocumentsContract.Document.COLUMN_FLAGS
      )

    val projection = arrayOf(
      *columns,
      *requiredColumns,
      *intrinsicColumns
    ).toSet().toTypedArray()

    val cursor = context.contentResolver.query(
      children,
      projection,
      // TODO: Add support for `selection`, `selectionArgs` and `sortOrder`
      null,
      null,
      null
    ) ?: return false

    try {
      if (cursor.count == 0) {
        return false
      }

      while (cursor.moveToNext()) {
        val data = mutableMapOf<String, Any?>()

        for (column in projection) {
          val columnValue: Any? = cursorHandlerOf(typeOfColumn(column)!!)(
            cursor,
            cursor.getColumnIndexOrThrow(column)
          )

          data[column] = columnValue
        }

        val mimeType =
          data[DocumentsContract.Document.COLUMN_MIME_TYPE] as String?

        val id =
          data[DocumentsContract.Document.COLUMN_DOCUMENT_ID] as String

        val isDirectory = if (mimeType != null) isDirectory(mimeType) else null

        val uri = DocumentsContract.buildDocumentUriUsingTree(
          rootUri,
          DocumentsContract.getDocumentId(
            DocumentsContract.buildDocumentUri(parent.authority, id)
          )
        )

        if (isDirectory == true && !rootOnly) {
          val nextChildren =
            DocumentsContract.buildChildDocumentsUriUsingTree(targetUri, id)

          val nextNode = Pair(uri, nextChildren)

          dirNodes.add(nextNode)
        }

        block(
          ScopedFileSystemEntity(
            parentUri = parent,
            uri = uri,
            displayName = data[DocumentsContract.Document.COLUMN_DISPLAY_NAME] as String,
            id = data[DocumentsContract.Document.COLUMN_DOCUMENT_ID] as String,
            entityType = if (isDirectory == true) "directory" else "file",
            mimeType = data[DocumentsContract.Document.COLUMN_MIME_TYPE] as String,
            length = data[DocumentsContract.Document.COLUMN_SIZE] as Long,
            lastModified = data[DocumentsContract.Document.COLUMN_LAST_MODIFIED] as Long
          ).toMap(),
          dirNodes.isEmpty() && cursor.isLast
        )
      }
    } finally {
      closeQuietly(cursor)
    }
  }

  return true
}

@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
fun traverseDirectoryEntries(
  context: Context,
  targetUri: Uri,
  columns: Array<String>,
  rootOnly: Boolean,
  block: (data: Map<String, Any?>, isLast: Boolean) -> Unit
): Boolean {
  return when {
    targetUri.isMediaFile || targetUri.isMediaDocument -> traverseMediaDirectoryEntries(
      context = context,
      targetUri = targetUri,
      columns = columns,
      rootOnly = rootOnly,
      block = block,
    )

    else -> traverseSafDirectoryEntries(
      context = context,
      targetUri = targetUri,
      columns = columns,
      rootOnly = rootOnly,
      block = block,
    )
  }
}


fun bitmapToBase64(bitmap: Bitmap): String {
  val outputStream = ByteArrayOutputStream()

  val fullQuality = 100

  bitmap.compress(Bitmap.CompressFormat.PNG, fullQuality, outputStream)

  return Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)
}

/**
 * Trick to verify if is a tree URI even not in API 26+
 */
fun isTreeUri(uri: Uri): Boolean {
  if (Build.VERSION.SDK_INT >= API_24) {
    return DocumentsContract.isTreeUri(uri)
  }

  val paths = uri.pathSegments

  return paths.size >= 2 && "tree" == paths[0]
}
