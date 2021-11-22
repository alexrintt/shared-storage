package io.lakscastro.sharedstorage

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** SharedStoragePlugin */
class SharedStoragePlugin :
  FlutterPlugin,
  MethodCallHandler,
  ActivityAware,
  PluginRegistry.ActivityResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  private var binding: ActivityPluginBinding? = null

  private val activity
    get(): Activity? = binding?.activity

  private val pendingResults: MutableMap<Int, Result> = mutableMapOf()

  companion object {
    const val METHOD_CHANNEL_NAME = "io.lakscastro.plugins/sharedstorage"

    const val GET_EXTERNAL_STORAGE_PUBLIC_DIRECTORY =
      "getExternalStoragePublicDirectory"
    const val GET_EXTERNAL_STORAGE_DIRECTORY = "getExternalStorageDirectory"

    const val GET_MEDIA_STORE_CONTENT_DIRECTORY =
      "getMediaStoreContentDirectory"
    const val GET_ROOT_DIRECTORY = "getRootDirectory"

    const val OPEN_DOCUMENT_TREE = "openDocumentTree"
    const val OPEN_DOCUMENT_TREE_CODE = 10

    const val CREATE_DOCUMENT_FILE = "createDocumentFile"
    const val PERSISTED_URI_PERMISSIONS = "persistedUriPermissions"
    const val RELEASE_PERSISTABLE_URI_PERMISSION =
      "releasePersistableUriPermission"
  }

  override fun onAttachedToEngine(
    @NonNull flutterPluginBinding: FlutterPluginBinding
  ) {
    context = flutterPluginBinding.applicationContext
    channel =
      MethodChannel(
        flutterPluginBinding.binaryMessenger,
        METHOD_CHANNEL_NAME
      )
    channel.setMethodCallHandler(this)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.binding = binding

    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  /// Allow usage of [this] as [MethodCallHandler]
  override fun onMethodCall(
    @NonNull call: MethodCall,
    @NonNull result: Result
  ) {
    when (call.method) {
      GET_EXTERNAL_STORAGE_PUBLIC_DIRECTORY ->
        getExternalStoragePublicDirectory(
          result,
          call.argument<String?>("directory") as String
        )
      GET_EXTERNAL_STORAGE_DIRECTORY ->
        getExternalStorageDirectory(result)
      GET_MEDIA_STORE_CONTENT_DIRECTORY ->
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
          getMediaStoreContentDirectory(
            result,
            call.argument<String?>("collection") as String
          )
        else result.notImplemented()
      GET_ROOT_DIRECTORY -> getRootDirectory(result)
      OPEN_DOCUMENT_TREE ->
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
          openDocumentTree(result)
      CREATE_DOCUMENT_FILE ->
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
          createDocumentFile(
            result,
            call.argument<String?>("mimeType") as String,
            call.argument<String?>("displayName") as String,
            call.argument<String?>("directoryUri") as String,
            call.argument<String?>("content") as String
          )
        }
      PERSISTED_URI_PERMISSIONS ->
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
          persistedUriPermissions(result)
      RELEASE_PERSISTABLE_URI_PERMISSION ->
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
          releasePersistableUriPermission(
            result,
            call.argument<String?>("directoryUri") as String
          )
      else -> result.notImplemented()
    }
  }

  private fun getExternalStoragePublicDirectory(
    result: Result,
    directory: String
  ) = result.success(environmentDirectoryOf(directory).absolutePath)

  private fun getExternalStorageDirectory(result: Result) =
    result.success(Environment.getExternalStorageDirectory().absolutePath)

  @RequiresApi(Build.VERSION_CODES.Q)
  private fun getMediaStoreContentDirectory(
    result: Result,
    collection: String
  ) = result.success(mediaStoreOf(collection))

  private fun getRootDirectory(result: Result) =
    result.success(Environment.getRootDirectory().absolutePath)

  @RequiresApi(Build.VERSION_CODES.O)
  private fun openDocumentTree(result: Result) {
    val intent =
      Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
        addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
      }

    if (pendingResults[OPEN_DOCUMENT_TREE_CODE] != null) return

    pendingResults[OPEN_DOCUMENT_TREE_CODE] = result

    activity?.startActivityForResult(intent, OPEN_DOCUMENT_TREE_CODE)
  }

  @RequiresApi(Build.VERSION_CODES.KITKAT)
  private fun createDocumentFile(
    result: Result,
    mimeType: String,
    displayName: String,
    directory: String,
    content: String
  ) {
    val parentUri = Uri.parse(directory)

    val parentDocumentDirectory =
      DocumentFile.fromTreeUri(context, parentUri)

    val createdFile =
      parentDocumentDirectory?.createFile(mimeType, displayName)

    createdFile?.uri?.apply {
      context.contentResolver.openOutputStream(this)?.apply {
        write(content.toByteArray())
        flush()
        result.success(path)
      }
    }
  }

  @RequiresApi(Build.VERSION_CODES.KITKAT)
  private fun persistedUriPermissions(result: Result) {
    val persistedUriPermissions =
      context.contentResolver.persistedUriPermissions

    result.success(
      persistedUriPermissions
        .map {
          mapOf(
            "isReadPermission" to it.isReadPermission,
            "isWritePermission" to it.isWritePermission,
            "persistedTime" to it.persistedTime,
            "uri" to "${it.uri}"
          )
        }
        .toList()
    )
  }

  @RequiresApi(Build.VERSION_CODES.KITKAT)
  private fun releasePersistableUriPermission(
    result: Result,
    directoryUri: String
  ) {
    context.contentResolver.releasePersistableUriPermission(
      Uri.parse(directoryUri),
      Intent.FLAG_GRANT_WRITE_URI_PERMISSION
    )

    result.success(null)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    binding?.removeActivityResultListener(this)
  }

  override fun onReattachedToActivityForConfigChanges(
    binding: ActivityPluginBinding
  ) {
    this.binding = binding
  }

  override fun onDetachedFromActivity() {
    binding = null
  }

  @RequiresApi(Build.VERSION_CODES.Q)
  override fun onActivityResult(
    requestCode: Int,
    resultCode: Int,
    data: Intent?
  ): Boolean {
    when (requestCode) {
      OPEN_DOCUMENT_TREE_CODE -> {
        try {
          val uri = data?.data

          if (uri != null) {
            context.contentResolver.takePersistableUriPermission(
              uri,
              Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            )

            pendingResults[OPEN_DOCUMENT_TREE_CODE]?.success("$uri")

            return true
          }
        } finally {
          pendingResults.remove(OPEN_DOCUMENT_TREE_CODE)
        }
      }
    }

    return false
  }
}
