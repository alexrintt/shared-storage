package io.lakscastro.sharedstorage.saf

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.documentfile.provider.DocumentFile
import io.flutter.plugin.common.*
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.lakscastro.sharedstorage.ROOT_CHANNEL
import io.lakscastro.sharedstorage.SharedStoragePlugin
import io.lakscastro.sharedstorage.plugin.*
import io.lakscastro.sharedstorage.saf.utils.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.FileNotFoundException
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream

internal class DocumentFileApi(private val plugin: SharedStoragePlugin) :
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
    private const val CHANNEL = "documentfile"
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      GET_DOCUMENT_CONTENT -> {
        val uri = Uri.parse(call.argument<String>("uri")!!)

        if (Build.VERSION.SDK_INT >= API_21) {
          CoroutineScope(Dispatchers.IO).launch {
            val content = readDocumentContent(uri)

            launch(Dispatchers.Main) {
              result.success(content)
            }
          }
        } else {
          result.notSupported(call.method, API_21)
        }
      }
      OPEN_DOCUMENT_TREE ->
        if (Build.VERSION.SDK_INT >= API_21) {
          openDocumentTree(call, result)
        }
      CREATE_FILE ->
        if (Build.VERSION.SDK_INT >= API_21) {
          createFile(
            result,
            call.argument<String>("mimeType")!!,
            call.argument<String>("displayName")!!,
            call.argument<String>("directoryUri")!!,
            call.argument<ByteArray>("content")!!
          )
        }
      PERSISTED_URI_PERMISSIONS ->
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
          persistedUriPermissions(result)
        }
      RELEASE_PERSISTABLE_URI_PERMISSION ->
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
          releasePersistableUriPermission(
            result,
            call.argument<String?>("uri") as String
          )
        }
      FROM_TREE_URI ->
        if (Build.VERSION.SDK_INT >= API_21) {
          result.success(
            createDocumentFileMap(
              documentFromUri(
                plugin.context,
                call.argument<String?>("uri") as String
              )
            )
          )
        }
      CAN_WRITE ->
        if (Build.VERSION.SDK_INT >= API_21) {
          result.success(
            documentFromUri(
              plugin.context,
              call.argument<String?>("uri") as String
            )?.canWrite()
          )
        }
      CAN_READ ->
        if (Build.VERSION.SDK_INT >= API_21) {
          val uri = call.argument<String?>("uri") as String

          result.success(
            documentFromUri(plugin.context, uri)?.canRead()
          )
        }
      LENGTH ->
        if (Build.VERSION.SDK_INT >= API_21) {
          result.success(
            documentFromUri(
              plugin.context,
              call.argument<String?>("uri") as String
            )?.length()
          )
        }
      EXISTS ->
        if (Build.VERSION.SDK_INT >= API_21) {
          result.success(
            documentFromUri(
              plugin.context,
              call.argument<String?>("uri") as String
            )?.exists()
          )
        }
      DELETE ->
        if (Build.VERSION.SDK_INT >= API_21) {
          result.success(
            documentFromUri(
              plugin.context,
              call.argument<String?>("uri") as String
            )?.delete()
          )
        }
      LAST_MODIFIED ->
        if (Build.VERSION.SDK_INT >= API_21) {
          result.success(
            documentFromUri(
              plugin.context,
              call.argument<String?>("uri") as String
            )?.lastModified()
          )
        }
      CREATE_DIRECTORY -> {
        if (Build.VERSION.SDK_INT >= API_21) {
          val uri = call.argument<String?>("uri") as String
          val displayName =
            call.argument<String?>("displayName") as String

          val createdDirectory =
            documentFromUri(plugin.context, uri)?.createDirectory(
              displayName
            ) ?: return

          result.success(createDocumentFileMap(createdDirectory))
        } else {
          result.notSupported(call.method, API_21)
        }
      }
      FIND_FILE -> {
        if (Build.VERSION.SDK_INT >= API_21) {
          val uri = call.argument<String?>("uri") as String
          val displayName =
            call.argument<String?>("displayName") as String

          result.success(
            createDocumentFileMap(
              documentFromUri(plugin.context, uri)?.findFile(displayName)
            )
          )
        }
      }
      COPY -> {
        if (Build.VERSION.SDK_INT >= API_21) {
          val destination =
            Uri.parse(call.argument<String>("destination")!!)

          val uri = Uri.parse(call.argument<String>("uri")!!)

          if (Build.VERSION.SDK_INT >= API_24) {
            DocumentsContract.copyDocument(
              plugin.context.contentResolver,
              uri,
              destination
            )
          } else {
            val inputStream = openInputStream(uri)
            val outputStream = openOutputStream(destination)

            outputStream?.let {
              inputStream?.copyTo(it)
            }
          }
        }
      }
      RENAME_TO -> {
        if (Build.VERSION.SDK_INT >= API_21) {
          val uri = call.argument<String?>("uri") as String
          val displayName =
            call.argument<String?>("displayName") as String

          documentFromUri(plugin.context, uri)?.apply {
            val success = renameTo(displayName)

            result.success(
              if (success)
                createDocumentFileMap(
                  documentFromUri(plugin.context, this.uri)!!
                )
              else null
            )
          }
        }
      }
      PARENT_FILE -> {
        if (Build.VERSION.SDK_INT >= API_21) {
          val uri = call.argument<String>("uri")!!
          val parent = documentFromUri(plugin.context, uri)?.parentFile

          result.success(
            if (parent != null)
              createDocumentFileMap(parent)
            else
              null
          )
        }
      }
      else -> result.notImplemented()
    }
  }

  @RequiresApi(API_21)
  private fun openDocumentTree(call: MethodCall, result: MethodChannel.Result) {
    val grantWritePermission =
      call.argument<Boolean>("grantWritePermission")!!

    val initialUri = call.argument<String>("initialUri")

    val intent =
      Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
        addFlags(
          if (grantWritePermission)
            Intent.FLAG_GRANT_WRITE_URI_PERMISSION
          else
            Intent.FLAG_GRANT_READ_URI_PERMISSION
        )

        if (initialUri != null) {
          val tree =
            DocumentFile.fromTreeUri(plugin.context, Uri.parse(initialUri))

          if (Build.VERSION.SDK_INT >= API_26) {
            putExtra(
              DocumentsContract.EXTRA_INITIAL_URI,
              tree?.uri
            )
          }
        }
      }

    if (pendingResults[OPEN_DOCUMENT_TREE_CODE] != null) return

    pendingResults[OPEN_DOCUMENT_TREE_CODE] = Pair(call, result)

    plugin.binding?.activity?.startActivityForResult(
      intent,
      OPEN_DOCUMENT_TREE_CODE
    )
  }

  @RequiresApi(API_21)
  private fun createFile(
    result: MethodChannel.Result,
    mimeType: String,
    displayName: String,
    directory: String,
    content: ByteArray
  ) {
    createFile(
      Uri.parse(directory),
      mimeType,
      displayName,
      content
    ) {
      result.success(createDocumentFileMap(this))
    }
  }

  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  private fun createFile(
    treeUri: Uri,
    mimeType: String,
    displayName: String,
    content: ByteArray,
    block: DocumentFile?.() -> Unit
  ) {

    val createdFile = documentFromUri(plugin.context, treeUri)!!.createFile(
      mimeType,
      displayName
    )

    createdFile?.uri?.apply {
      plugin.context.contentResolver.openOutputStream(this)?.apply {
        write(content)
        flush()

        val createdFileDocument =
          documentFromUri(plugin.context, createdFile.uri)

        block(createdFileDocument)
      }
    }
  }

  @RequiresApi(API_19)
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
        }.toList()
    )
  }

  @RequiresApi(API_19)
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

  @RequiresApi(API_19)
  override fun onActivityResult(
    requestCode: Int,
    resultCode: Int,
    data: Intent?
  ): Boolean {
    when (requestCode) {
      OPEN_DOCUMENT_TREE_CODE -> {
        val pendingResult =
          pendingResults[OPEN_DOCUMENT_TREE_CODE] ?: return false

        val grantWritePermission =
          pendingResult.first.argument<Boolean>("grantWritePermission")!!

        try {
          val uri = data?.data

          if (uri != null) {
            plugin.context.contentResolver
              .takePersistableUriPermission(
                uri,
                if (grantWritePermission)
                  Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                else
                  Intent.FLAG_GRANT_READ_URI_PERMISSION
              )

            pendingResult.second.success("$uri")

            return true
          }

          pendingResult.second.success(null)
        } finally {
          pendingResults.remove(OPEN_DOCUMENT_TREE_CODE)
        }
      }
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
      LIST_FILES -> listFilesEvent(eventSink, args)
    }
  }

  /**
   * Read files of a given `uri` and dispatches all files under it through
   * the `eventSink` and closes the stream after the last record
   *
   * Useful to read files under a `uri` with a large set of children
   */
  private fun listFilesEvent(
    eventSink: EventChannel.EventSink?,
    args: Map<*, *>
  ) {
    if (eventSink == null) return

    val document = if (Build.VERSION.SDK_INT >= API_24) {
      documentFromUri(plugin.context, args["uri"] as String) ?: return
    } else {
      null
    }

    if (document == null) {
      eventSink.error(
        EXCEPTION_NOT_SUPPORTED,
        "Android SDK must be greater or equal than [Build.VERSION_CODES.N]",
        "Got (Build.VERSION.SDK_INT): ${Build.VERSION.SDK_INT}"
      )
    } else {
      val columns = args["columns"] as List<*>

      if (!document.canRead()) {
        val error =
          "You cannot read a URI that you don't have read permissions"

        Log.d("NO PERMISSION!!!", error)

        eventSink.error(
          EXCEPTION_MISSING_PERMISSIONS,
          error,
          mapOf("uri" to args["uri"])
        )

        eventSink.endOfStream()
      } else {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {

          CoroutineScope(Dispatchers.IO).launch {
            try {
              traverseDirectoryEntries(
                plugin.context.contentResolver,
                rootOnly = true,
                rootUri = document.uri,
                columns = columns.map {
                  parseDocumentFileColumn(
                    parseDocumentFileColumn(it as String)!!
                  )
                }.toTypedArray()
              ) { data, _ ->
                launch(Dispatchers.Main) {
                  eventSink.success(data)
                }
              }
            } finally {
              launch(Dispatchers.Main) {
                eventSink.endOfStream()
              }
            }
          }
        }
      }
    }
  }

  /**
   * Alias for `plugin.context.contentResolver.openOutputStream(uri)`
   */
  private fun openOutputStream(uri: Uri): OutputStream? {
    return plugin.context.contentResolver.openOutputStream(uri)
  }

  /**
   * Alias for `plugin.context.contentResolver.openInputStream(uri)`
   */
  private fun openInputStream(uri: Uri): InputStream? {
    return plugin.context.contentResolver.openInputStream(uri)
  }

  /**
   * Get a document content as `ByteArray` equivalent to `Uint8List` in Dart
   */
  @RequiresApi(API_21)
  private fun readDocumentContent(uri: Uri): ByteArray? {
    return try {
      val inputStream = openInputStream(uri)

      val bytes = inputStream?.readBytes()

      inputStream?.close()

      bytes
    } catch (e: FileNotFoundException) {
      null
    } catch (e: IOException) {
      null
    }
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }
}
