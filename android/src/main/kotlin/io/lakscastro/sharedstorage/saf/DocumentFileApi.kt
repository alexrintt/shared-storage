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
import io.lakscastro.sharedstorage.plugin.*
import io.lakscastro.sharedstorage.saf.utils.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.BufferedReader
import java.io.InputStreamReader

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
              documentFromTreeUri(
                plugin.context,
                call.argument<String?>("uri") as String
              )
            )
          )
        }
      CAN_WRITE ->
        if (Build.VERSION.SDK_INT >= API_21) {
          result.success(
            documentFromTreeUri(
              plugin.context,
              call.argument<String?>("uri") as String
            )?.canWrite()
          )
        }
      CAN_READ ->
        if (Build.VERSION.SDK_INT >= API_21) {
          result.success(
            documentFromTreeUri(
              plugin.context,
              call.argument<String?>("uri") as String
            )?.canRead()
          )
        }
      LENGTH ->
        if (Build.VERSION.SDK_INT >= API_21) {
          result.success(
            documentFromTreeUri(
              plugin.context,
              call.argument<String?>("uri") as String
            )?.length()
          )
        }
      EXISTS ->
        if (Build.VERSION.SDK_INT >= API_21) {
          result.success(
            documentFromTreeUri(
              plugin.context,
              call.argument<String?>("uri") as String
            )?.exists()
          )
        }
      DELETE ->
        if (Build.VERSION.SDK_INT >= API_21) {
          result.success(
            documentFromTreeUri(
              plugin.context,
              call.argument<String?>("uri") as String
            )?.delete()
          )
        }
      LAST_MODIFIED ->
        if (Build.VERSION.SDK_INT >= API_21) {
          result.success(
            documentFromTreeUri(
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
            documentFromTreeUri(plugin.context, uri)?.createDirectory(displayName) ?: return

          result.success(createDocumentFileMap(createdDirectory))
        }
      }
      FIND_FILE -> {
        if (Build.VERSION.SDK_INT >= API_21) {
          val uri = call.argument<String?>("uri") as String
          val displayName =
            call.argument<String?>("displayName") as String

          result.success(
            createDocumentFileMap(
              documentFromTreeUri(plugin.context, uri)?.findFile(displayName)
            )
          )
        }
      }
      COPY -> {
        if (Build.VERSION.SDK_INT >= API_21) {
          val content = StringBuilder()
          val destinationTree = call.argument<String>("destination")!!
          val document = documentFromTreeUri(
            plugin.context,
            Uri.parse(call.argument<String>("uri")!!)
          ) ?: return

          readDocumentContent(document.uri) {
            onSuccess = { content.append(this) }
            onEnd = {
              createFile(
                result,
                document.type!!,
                document.name!!,
                destinationTree,
                "$content".toByteArray()
              )
            }
          }
        }
      }
      RENAME_TO -> {
        if (Build.VERSION.SDK_INT >= API_21) {
          val uri = call.argument<String?>("uri") as String
          val displayName =
            call.argument<String?>("displayName") as String

          documentFromTreeUri(plugin.context, uri)?.apply {
            val success = renameTo(displayName)

            result.success(
              if (success)
                createDocumentFileMap(
                  documentFromTreeUri(plugin.context, this.uri)!!
                )
              else null
            )
          }
        }
      }
      PARENT_FILE -> {
        if (Build.VERSION.SDK_INT >= API_21) {
          val uri = call.argument<String>("uri")!!
          val parent = documentFromTreeUri(plugin.context, uri)?.parentFile

          result.success(if (parent != null) createDocumentFileMap(parent) else null)
        }
      }
      else -> result.notImplemented()
    }
  }

  @RequiresApi(API_21)
  private fun openDocumentTree(call: MethodCall, result: MethodChannel.Result) {
    val grantWritePermission = call.argument<Boolean>("grantWritePermission")!!
    val initialUri = call.argument<String>("initialUri")

    val intent =
      Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
        addFlags(if (grantWritePermission) Intent.FLAG_GRANT_WRITE_URI_PERMISSION else Intent.FLAG_GRANT_READ_URI_PERMISSION)

        if (initialUri != null) {
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(initialUri))
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

    createdFile?.uri?.apply {
      plugin.context.contentResolver.openOutputStream(this)?.apply {
        write(content)
        flush()

        val createdFileDocument =
          documentFromTreeUri(plugin.context, createdFile.uri)

        result.success(createDocumentFileMap(createdFileDocument))
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
        val pendingResult = pendingResults[OPEN_DOCUMENT_TREE_CODE] ?: return false

        try {
          val uri = data?.data

          if (uri != null) {
            plugin.context.contentResolver
              .takePersistableUriPermission(
                uri,
                if (pendingResult.first.argument<Boolean>("grantWritePermission")!!)
                  Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                else
                  Intent.FLAG_GRANT_READ_URI_PERMISSION
              )

            pendingResult.second.success("$uri")

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
      LIST_FILES -> {
        if (eventSink == null) return

        val document = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
          documentFromTreeUri(plugin.context, args["uri"] as String) ?: return
        } else {
          null
        }

        if (document == null) {
          eventSink?.error(
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

            eventSink?.error(
              EXCEPTION_MISSING_PERMISSIONS,
              error,
              mapOf("uri" to args["uri"])
            )
          } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
              CoroutineScope(Dispatchers.Default).launch {
                traverseDirectoryEntries(
                  plugin.context.contentResolver,
                  rootOnly = true,
                  rootUri = document.uri,
                  columns = columns.map {
                    parseDocumentFileColumn(
                      parseDocumentFileColumn(it as String)!!
                    )!!
                  }.toTypedArray()
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
      GET_DOCUMENT_CONTENT -> {
        val uri = Uri.parse(args["uri"] as String)

        readDocumentContent(uri) {
          onSuccess = { eventSink?.success(this) }
          onEnd = { eventSink?.endOfStream() }
        }
      }
    }
  }

  private fun readDocumentContent(
    uri: Uri,
    handler: CallbackHandler<String>.() -> Unit
  ) {
    val callbacks = CallbackHandler<String>().apply { handler(this) }

    plugin.context.contentResolver.openInputStream(uri)
      ?.use { inputStream ->
        BufferedReader(InputStreamReader(inputStream)).use { reader ->
          var line = reader.readLine()

          while (line != null) {
            callbacks.onSuccess?.invoke(line)

            line = reader.readLine()
          }

          callbacks.onEnd?.invoke()
        }
      }
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }
}


