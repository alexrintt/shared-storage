package io.lakscastro.sharedstorage.storageaccessframework

import android.content.ActivityNotFoundException
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import androidx.core.content.PermissionChecker
import io.flutter.plugin.common.*
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.lakscastro.sharedstorage.ROOT_CHANNEL
import io.lakscastro.sharedstorage.SharedStoragePlugin
import io.lakscastro.sharedstorage.plugin.API_19
import io.lakscastro.sharedstorage.plugin.ActivityListener
import io.lakscastro.sharedstorage.plugin.Listenable
import io.lakscastro.sharedstorage.plugin.notSupported
import io.lakscastro.sharedstorage.storageaccessframework.lib.*


/**
 * Aimed to be a class which takes the `DocumentFile` API and implement
 * some APIs not supported natively by Android.
 *
 * This is why it is separated from the original and raw `DocumentFileApi`
 * which is the class that only exposes the APIs without modifying them
 *
 * Then here is where we can implement the main abstractions/use-cases
 * which would be available globally without modifying the strict APIs
 */
internal class DocumentFileHelperApi(private val plugin: SharedStoragePlugin) :
  MethodChannel.MethodCallHandler,
  PluginRegistry.ActivityResultListener,
  Listenable,
  ActivityListener,
  StreamHandler {
  private val pendingResults: MutableMap<Int, Pair<MethodCall, MethodChannel.Result>> =
    mutableMapOf()
  private var channel: MethodChannel? = null
  private var eventChannel: EventChannel? = null
  private var eventSink: EventChannel.EventSink? = null

  companion object {
    private const val CHANNEL = "documentfilehelper"
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      OPEN_DOCUMENT_FILE -> openDocumentFile(call, result)
      GET_REAL_PATH_FROM_URI -> getRealPathFromUri(call, result)
      else -> result.notImplemented()
    }
  }

  private fun getRealPathFromUri(
    call: MethodCall,
    result: MethodChannel.Result
  ) {
    val uri = Uri.parse(call.argument<String>("uri")!!)
    if (Build.VERSION.SDK_INT >= API_19) {
      result.success(getPath(plugin.context, uri))
    } else {
      result.notSupported(
        GET_REAL_PATH_FROM_URI,
        API_19,
        mapOf("uri" to "$uri")
      )
    }
  }

  private fun openDocumentFile(call: MethodCall, result: MethodChannel.Result) {
    val uri = Uri.parse(call.argument<String>("uri")!!)
    val type =
      call.argument<String>("type") ?: plugin.context.contentResolver.getType(
        uri
      )

    val intent =
      Intent(Intent.ACTION_VIEW).apply {
        addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        addCategory(Intent.CATEGORY_DEFAULT)

        val uriWithProviderScheme = Uri.Builder().let {
          it.scheme(uri.scheme)
          it.path(uri.path)
          it.query(uri.query)
          it.authority(uri.authority)
          it.build()
        }

        setDataAndType(uriWithProviderScheme, type)
      }

    try {
      plugin.binding?.activity?.startActivity(intent, null)

      Log.d("sharedstorage", "Successfully launched uri $uri ")

      result.success(null)
    } catch (e: ActivityNotFoundException) {
      result.error(
        EXCEPTION_ACTIVITY_NOT_FOUND,
        "There's no activity handler that can process the uri $uri of type $type",
        mapOf(
          "uri" to "$uri",
          "type" to type
        )
      )
    } catch (e: SecurityException) {
      result.error(
        EXCEPTION_CANT_OPEN_FILE_DUE_SECURITY_POLICY,
        "Missing read and write permissions for uri $uri of type $type to launch ACTION_VIEW activity",
        mapOf(
          "uri" to "$uri",
          "type" to "$type"
        )
      )
    } catch (e: Throwable) {
      result.error(
        EXCEPTION_CANT_OPEN_DOCUMENT_FILE,
        "Couldn't start activity to open document file for uri: $uri",
        mapOf("uri" to "$uri")
      )
    }
  }

  private fun hasPermission(permission: String): Boolean {
    return ContextCompat.checkSelfPermission(
      plugin.binding!!.activity,
      permission
    ) == PermissionChecker.PERMISSION_GRANTED
  }

  /**
   * Get a file path from a Uri. This will get the the path for Storage Access
   * Framework Documents, as well as the _data field for the MediaStore and
   * other file-based ContentProviders.
   *
   * @param context The context.
   * @param uri The Uri to query.
   * @author paulburke
   */
  @RequiresApi(Build.VERSION_CODES.KITKAT)
  fun getPath(context: Context, uri: Uri): String? {
    val isKitKat: Boolean = Build.VERSION.SDK_INT >= API_19

    // DocumentProvider
    if (isKitKat && DocumentsContract.isDocumentUri(context, uri)) {
      // ExternalStorageProvider
      if (isExternalStorageDocument(uri)) {
        val docId: String = DocumentsContract.getDocumentId(uri)
        val split = docId.split(":").toTypedArray()
        val type = split[0]
        if ("primary".equals(type, ignoreCase = true)) {
          return Environment.getExternalStorageDirectory()
            .toString() + "/" + split[1]
        }

        // TODO handle non-primary volumes
      } else if (isDownloadsDocument(uri)) {
        val id: String = DocumentsContract.getDocumentId(uri)
        val contentUri: Uri = ContentUris.withAppendedId(
          Uri.parse("content://downloads/public_downloads"),
          java.lang.Long.valueOf(id)
        )

        return getDataColumn(context, contentUri, null, null)
      } else if (isMediaDocument(uri)) {
        val docId: String = DocumentsContract.getDocumentId(uri)
        val split = docId.split(":").toTypedArray()

        val contentUri: Uri? = when (split[0]) {
          "image" -> MediaStore.Images.Media.EXTERNAL_CONTENT_URI
          "video" -> MediaStore.Video.Media.EXTERNAL_CONTENT_URI
          "audio" -> MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
          else -> null
        }

        val selection = "_id=?"
        val selectionArgs = arrayOf(split[1])

        contentUri?.let {
          return getDataColumn(context, it, selection, selectionArgs)
        }
      }
    } else if ("content".equals(uri.scheme, ignoreCase = true)) {
      return getDataColumn(context, uri, null, null)
    } else if ("file".equals(uri.scheme, ignoreCase = true)) {
      return uri.path
    }

    return null
  }

  /**
   * Get the value of the data column for this Uri. This is useful for
   * MediaStore Uris, and other file-based ContentProviders.
   *
   * @param context The context.
   * @param uri The Uri to query.
   * @param selection (Optional) Filter used in the query.
   * @param selectionArgs (Optional) Selection arguments used in the query.
   * @return The value of the _data column, which is typically a file path.
   */
  private fun getDataColumn(
    context: Context, uri: Uri, selection: String?,
    selectionArgs: Array<String>?
  ): String? {
    var cursor: Cursor? = null
    val column = "_data"
    val projection = arrayOf(
      column
    )
    try {
      cursor = context.contentResolver.query(
        uri, projection, selection, selectionArgs,
        null
      )
      if (cursor != null && cursor.moveToFirst()) {
        val columnIndex: Int = cursor.getColumnIndexOrThrow(column)

        return cursor.getString(columnIndex)
      }
    } finally {
      cursor?.close()
    }
    return null
  }


  /**
   * @param uri The Uri to check.
   * @return Whether the Uri authority is ExternalStorageProvider.
   */
  private fun isExternalStorageDocument(uri: Uri): Boolean {
    return "com.android.externalstorage.documents" == uri.authority
  }

  /**
   * @param uri The Uri to check.
   * @return Whether the Uri authority is DownloadsProvider.
   */
  fun isDownloadsDocument(uri: Uri): Boolean {
    return "com.android.providers.downloads.documents" == uri.authority
  }

  /**
   * @param uri The Uri to check.
   * @return Whether the Uri authority is MediaProvider.
   */
  private fun isMediaDocument(uri: Uri): Boolean {
    return "com.android.providers.media.documents" == uri.authority
  }

  override fun onActivityResult(
    requestCode: Int,
    resultCode: Int,
    data: Intent?
  ): Boolean {
    when (requestCode) {
      /**
       * TODO(@lakscastro): Implement if required
       */
      else -> return true
    }

    return false
  }

  override fun startListening(binaryMessenger: BinaryMessenger) {
    if (channel != null) stopListening()

    channel = MethodChannel(binaryMessenger, "$ROOT_CHANNEL/$CHANNEL")
    channel?.setMethodCallHandler(this)

    eventChannel =
      EventChannel(binaryMessenger, "$ROOT_CHANNEL/event/$CHANNEL")
    eventChannel?.setStreamHandler(this)
  }

  override fun stopListening() {
    if (channel == null) return

    channel?.setMethodCallHandler(null)
    channel = null

    eventChannel?.setStreamHandler(null)
    eventChannel = null
  }

  override fun startListeningToActivity() {
    plugin.binding?.addActivityResultListener(this)
  }

  override fun stopListeningToActivity() {
    plugin.binding?.removeActivityResultListener(this)
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    val args = arguments as Map<*, *>

    eventSink = events

    when (args["event"]) {
      /**
       * TODO(@lakscastro): Implement if required
       */
    }
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }
}
