package io.lakscastro.sharedstorage.saf

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.*
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.lakscastro.sharedstorage.ROOT_CHANNEL
import io.lakscastro.sharedstorage.SharedStoragePlugin
import io.lakscastro.sharedstorage.plugin.ActivityListener
import io.lakscastro.sharedstorage.plugin.Listenable
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class DocumentFileApi(private val plugin: SharedStoragePlugin) :
  MethodChannel.MethodCallHandler,
  PluginRegistry.ActivityResultListener,
  Listenable,
  ActivityListener,
  StreamHandler {
  private val pendingResults: MutableMap<Int, MethodChannel.Result> =
    mutableMapOf()
  private var channel: MethodChannel? = null
  private var eventChannel: EventChannel? = null
  private var eventSink: EventChannel.EventSink? = null

  @RequiresApi(Build.VERSION_CODES.O)
  private fun openDocumentTree(result: MethodChannel.Result) {
    val intent =
      Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
        addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
      }

    if (pendingResults[OPEN_DOCUMENT_TREE_CODE] != null) return

    pendingResults[OPEN_DOCUMENT_TREE_CODE] = result

    plugin.binding?.activity?.startActivityForResult(
      intent,
      OPEN_DOCUMENT_TREE_CODE
    )
  }

  @RequiresApi(Build.VERSION_CODES.KITKAT)
  private fun createFile(
    result: MethodChannel.Result,
    mimeType: String,
    displayName: String,
    directory: String,
    content: String
  ) {
    val documentFile =
      documentFromTreeUri(plugin.context, directory)
        ?: return result.error(
          EXCEPTION_PARENT_DOCUMENT_MUST_BE_DIRECTORY,
          "You can't create a file inside another file! You can call `createFile` method only on directory documents",
          mapOf(
            "invalidParentDirectory" to directory,
            "displayName" to displayName,
            "mimeType" to mimeType
          )
        )

    val createdFile = documentFile.createFile(mimeType, displayName)

    CoroutineScope(Dispatchers.Default).launch {
      createdFile?.uri?.apply {
        plugin.context.contentResolver.openOutputStream(this)?.apply {
          write(content.toByteArray())
          flush()

          val createdFileDocument =
            documentFromTreeUri(plugin.context, createdFile.uri)

          launch(Dispatchers.Main) {
            result.success(createDocumentFileMap(createdFileDocument))
          }
        }
      }
    }
  }

  @RequiresApi(Build.VERSION_CODES.KITKAT)
  private fun listFiles(result: MethodChannel.Result, uri: String) {
    CoroutineScope(Dispatchers.Default).launch {
      val documentsTree = documentFromTreeUri(plugin.context, uri)

      if (documentsTree != null) {
        val childDocuments = documentsTree.listFiles()

        val rawChildDocuments = childDocuments.map { createDocumentFileMap(it) }.toList()

        launch(Dispatchers.Main) {
          result.success(rawChildDocuments)
        }
      } else {
        launch(Dispatchers.Main) {
          result.error(
            EXCEPTION_PARENT_DOCUMENT_MUST_BE_DIRECTORY,
            "You must provide a valid parent URI",
            uri
          )
        }
      }
    }
  }

  @RequiresApi(Build.VERSION_CODES.KITKAT)
  private fun persistedUriPermissions(result: MethodChannel.Result) {
    val persistedUriPermissions =
      plugin.context.contentResolver.persistedUriPermissions

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
    result: MethodChannel.Result,
    directoryUri: String
  ) {
    plugin.context.contentResolver.releasePersistableUriPermission(
      Uri.parse(directoryUri),
      Intent.FLAG_GRANT_WRITE_URI_PERMISSION
    )

    result.success(null)
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
            plugin.context.contentResolver
              .takePersistableUriPermission(
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

  override fun startListening(binaryMessenger: BinaryMessenger) {
    if (channel != null) {
      stopListening()
    }

    channel = MethodChannel(binaryMessenger, "$ROOT_CHANNEL/documentfile")
    channel?.setMethodCallHandler(this)

    eventChannel =
      EventChannel(binaryMessenger, "$ROOT_CHANNEL/event/documentfile")
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
      LIST_FILES_AS_STREAM -> {
        if (eventSink == null) return

        val document = documentFromTreeUri(plugin.context, args["uri"] as String) ?: return
        val columns = args["columns"] as List<*>

        if (!document.canRead()) {
          val error = "You cannot read a URI that you don't have read permissions"

          Log.d("NO PERMISSION!!!", error)

          eventSink?.error(EXCEPTION_MISSING_PERMISSIONS, error, mapOf("uri" to args["uri"]))
        } else {
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            CoroutineScope(Dispatchers.Default).launch {
              traverseDirectoryEntries(
                plugin.context.contentResolver,
                rootOnly = true,
                rootUri = document.uri,
                columns = columns.map { parseDocumentFileColumn(parseDocumentFileColumn(it as String)!!)!! }
                  .toTypedArray()
              ) { data ->
                launch(Dispatchers.Main) {
                  eventSink?.success(data)
                }
              }
            }
          }
        }
      }
    }
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }
}
