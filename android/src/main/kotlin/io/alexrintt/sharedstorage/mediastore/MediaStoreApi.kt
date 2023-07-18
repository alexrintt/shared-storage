package io.alexrintt.sharedstorage.mediastore

import android.content.Context
import android.database.Cursor
import android.database.SQLException
import android.database.sqlite.SQLiteException
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.provider.OpenableColumns
import androidx.core.database.getStringOrNull
import androidx.documentfile.provider.DocumentFile
import com.anggrayudi.storage.extension.isMediaDocument
import com.anggrayudi.storage.extension.isMediaFile
import com.anggrayudi.storage.extension.isTreeDocumentFile
import com.anggrayudi.storage.file.DocumentFileCompat
import com.anggrayudi.storage.file.id
import com.anggrayudi.storage.file.mimeType
import com.anggrayudi.storage.file.mimeTypeByFileName
import com.anggrayudi.storage.media.MediaStoreCompat
import io.alexrintt.sharedstorage.ROOT_CHANNEL
import io.alexrintt.sharedstorage.SharedStoragePlugin
import io.alexrintt.sharedstorage.deprecated.lib.getDocumentsContractColumns
import io.alexrintt.sharedstorage.plugin.Listenable
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


data class ScopedFileSystemEntity(
  val id: String,
  val mimeType: String?,
  val length: Long,
  val displayName: String,
  val uri: Uri,
  val parentUri: Uri?,
  val lastModified: Long,
  val entityType: String
) {
  fun toMap(): Map<String, *> {
    return mapOf(
      "id" to id,
      "mimeType" to mimeType,
      "length" to length,
      "displayName" to displayName,
      "uri" to uri.toString(),
      "lastModified" to lastModified,
      "parentUri" to parentUri?.toString(),
      "entityType" to entityType,
    )
  }
}

fun getScopedFileSystemEntityFromMediaStoreUri(
  context: Context, uri: Uri
): ScopedFileSystemEntity? {
  val projection: MutableList<String> = mutableListOf(
    MediaStore.MediaColumns._ID,
    MediaStore.MediaColumns.DOCUMENT_ID,
    MediaStore.MediaColumns.DISPLAY_NAME,
    MediaStore.MediaColumns.SIZE,
    MediaStore.MediaColumns.MIME_TYPE,
    MediaStore.MediaColumns.DATE_MODIFIED,
    // TODO: Add support for mime type specific files (e.g [ALBUM_ARTIST] when the file is a mp3) but all inside a [extra] map field to not pollute/modify the [ScopedFileSystemEntity] interface.
  )

  var cursor: Cursor? = try {
    context.contentResolver.query(
      uri, projection.toTypedArray(), null, null, null
    )
  } catch (e: SQLiteException) {
    // Some android 8.0 devices throw "DOCUMENT_ID is not a column"
    projection.remove(MediaStore.MediaColumns.DOCUMENT_ID)
    context.contentResolver.query(
      uri, projection.toTypedArray(), null, null, null
    )
  }

  if (cursor != null && cursor.moveToFirst()) {
    val id: String?
    val idColumn = cursor.getColumnIndex(MediaStore.MediaColumns._ID)
    id = cursor.getStringOrNull(idColumn)

    val documentId: String?
    val documentIdColumn =
      cursor.getColumnIndex(MediaStore.MediaColumns.DOCUMENT_ID)
    documentId = cursor.getStringOrNull(documentIdColumn)

    val dateModified: Long
    val dateModifiedColumn =
      cursor.getColumnIndex(MediaStore.MediaColumns.DATE_MODIFIED)
    dateModified = cursor.getLong(dateModifiedColumn)

    val displayName: String
    val displayNameColumn =
      cursor.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME)
    displayName = cursor.getString(displayNameColumn)

    val mimeType: String
    val mimeTypeColumn =
      cursor.getColumnIndex(MediaStore.MediaColumns.MIME_TYPE)
    mimeType = cursor.getString(mimeTypeColumn)

    val size: Long
    val sizeColumn = cursor.getColumnIndex(MediaStore.MediaColumns.SIZE)
    size = cursor.getLong(sizeColumn)

    cursor.close()

    return ScopedFileSystemEntity(
      id = documentId ?: id ?: uri.toString(),
      mimeType = mimeType,
      length = size,
      displayName = displayName,
      uri = uri,
      parentUri = null,
      lastModified = dateModified,
      entityType = "file"
    )
  }

  return null
}

fun getOpenableUriNameAndLength(
  context: Context, uri: Uri
): Pair<String?, Long?> {
  context.contentResolver.query(uri, null, null, null, null)?.use {
    val nameIndex = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
    val sizeIndex = it.getColumnIndex(OpenableColumns.SIZE)
    it.moveToFirst()
    return Pair(it.getString(nameIndex), it.getLong(sizeIndex))
  }

  return Pair(null, null)
}

fun getScopedFileSystemEntityFromSafUri(
  context: Context, uri: Uri
): ScopedFileSystemEntity? {
  val documentTree = DocumentFileCompat.fromUri(context, uri) ?: return null

  return ScopedFileSystemEntity(
    id = documentTree.id,
    displayName = documentTree.name ?: Uri.decode(uri.lastPathSegment),
    uri = uri,
    length = documentTree.length(),
    parentUri = documentTree.parentFile?.uri,
    mimeType = documentTree.mimeType ?: documentTree.mimeTypeByFileName,
    lastModified = documentTree.lastModified(),
    entityType = if (documentTree.isDirectory) "directory" else "file"
  )
}

fun getScopedFileSystemEntityFromUri(
  context: Context, uri: Uri
): ScopedFileSystemEntity? {
  Log.d("getScopedFileSystemEntityFromUri1", uri.isMediaFile.toString())
  Log.d("getScopedFileSystemEntityFromUri1", uri.authority.toString())

  // Some devices do return "0@media" as URI authority when "sharing with"
  // so we need try to parse this URI using everything we can and know because scoped storage (SAF cof cof) is just about it:
  // parse unknown URIs using unknown columns by unknown providers with unknown or behavior, accept it.
  return getScopedFileSystemEntityFromUriUsingPredeterminedConstantConditionStrategy(
    context,
    uri
  ) ?: getScopedFileSystemEntityFromUriUsingTryCatchStrategy(context, uri)
}

fun getScopedFileSystemEntityFromUriUsingPredeterminedConstantConditionStrategy(
  context: Context,
  uri: Uri
): ScopedFileSystemEntity? {
  try {
    return when {
      uri.isMediaFile || uri.isMediaDocument -> getScopedFileSystemEntityFromMediaStoreUri(
        context,
        uri
      )

      else -> getScopedFileSystemEntityFromSafUri(context, uri)
    }
  } catch (e: Throwable) {
    Log.d(
      "URI PARSE FAILED",
      "[getScopedFileSystemEntityFromUriUsingPredeterminedConstantConditionStrategy] failed to parse URI $uri. Error: $e"
    )
    return null
  }
}

fun getScopedFileSystemEntityFromUriUsingTryCatchStrategy(
  context: Context,
  uri: Uri
): ScopedFileSystemEntity? {
  return try {
    getScopedFileSystemEntityFromMediaStoreUri(context, uri)
  } catch (e: Throwable) {
    getScopedFileSystemEntityFromSafUri(context, uri)
  }
}


class MediaStoreApi(val plugin: SharedStoragePlugin) :
  MethodChannel.MethodCallHandler, Listenable {
  private var channel: MethodChannel? = null

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "getScopedFileSystemEntityFromUri" -> {
        val uri = Uri.parse(call.argument<String>("uri")!!)

        val scopedFile = getScopedFileSystemEntityFromUri(
          plugin.context.applicationContext, uri
        )

        if (scopedFile == null) {
          result.error(
            "NOT_FOUND",
            "The URI $uri was not found: did not return any results",
            mapOf("uri" to uri.toString())
          )
        } else {
          result.success(scopedFile.toMap())
        }
      }

      else -> result.notImplemented()
    }
  }

  override fun startListening(binaryMessenger: BinaryMessenger) {
    if (channel != null) {
      stopListening()
    }

    channel = MethodChannel(binaryMessenger, "$ROOT_CHANNEL/mediastore")
    channel?.setMethodCallHandler(this)
  }

  override fun stopListening() {
    if (channel == null) return

    channel?.setMethodCallHandler(null)
    channel = null
  }
}
