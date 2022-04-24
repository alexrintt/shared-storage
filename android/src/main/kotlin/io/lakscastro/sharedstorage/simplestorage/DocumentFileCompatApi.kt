package io.lakscastro.sharedstorage.simplestorage

import android.content.Intent
import androidx.annotation.RequiresApi
import com.anggrayudi.storage.file.DocumentFileCompat
import com.anggrayudi.storage.file.DocumentFileType
import com.anggrayudi.storage.file.StorageId
import io.flutter.plugin.common.*
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.lakscastro.sharedstorage.ROOT_CHANNEL
import io.lakscastro.sharedstorage.SharedStoragePlugin
import io.lakscastro.sharedstorage.plugin.API_19
import io.lakscastro.sharedstorage.plugin.ActivityListener
import io.lakscastro.sharedstorage.plugin.Listenable
import io.lakscastro.sharedstorage.plugin.valueOf
import io.lakscastro.sharedstorage.simplestorage.lib.EXCEPTION_INVALID_DOCUMENT_TYPE
import io.lakscastro.sharedstorage.simplestorage.lib.FROM_FILE
import io.lakscastro.sharedstorage.simplestorage.lib.FROM_FULL_PATH
import io.lakscastro.sharedstorage.simplestorage.lib.FROM_SIMPLE_PATH
import io.lakscastro.sharedstorage.storageaccessframework.lib.createDocumentFileMap
import java.io.File

internal class DocumentFileCompatApi(private val plugin: SharedStoragePlugin) :
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
    private const val CHANNEL = "documentfilecompat"
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      FROM_SIMPLE_PATH -> fromSimplePath(call, result)
      FROM_FULL_PATH -> fromFullPath(call, result)
      FROM_FILE -> fromFile(call, result)
      else -> result.notImplemented()
    }
  }

  private fun fromSimplePath(call: MethodCall, result: MethodChannel.Result) {
    val storageId =
      call.argument<String>("storageId") ?: StorageId.PRIMARY
    val basePath = call.argument<String>("basePath") ?: ""
    val documentType = call.argument<String>("documentType")
    val documentTypeValue = valueOf<DocumentFileType>(documentType)
    val defaultDocumentTypeValue = documentTypeValue ?: DocumentFileType.ANY
    val requiresWriteAccess =
      call.argument<Boolean>("requiresWriteAccess") ?: false
    val considerRawFile =
      call.argument<Boolean>("considerRawFile") ?: true

    if (documentType != null && documentTypeValue == null) {
      throwInvalidDocumentType(result, documentType)
    } else {
      result.success(
        createDocumentFileMap(
          DocumentFileCompat.fromSimplePath(
            plugin.context,
            storageId = storageId,
            basePath = basePath,
            documentType = defaultDocumentTypeValue,
            requiresWriteAccess = requiresWriteAccess,
            considerRawFile = considerRawFile
          )
        )
      )
    }
  }

  private fun fromFullPath(call: MethodCall, result: MethodChannel.Result) {
    val fullPath = call.argument<String>("fullPath")!!
    val documentType = call.argument<String>("documentType")
    val documentTypeValue = valueOf<DocumentFileType>(documentType)
    val defaultDocumentTypeValue = documentTypeValue ?: DocumentFileType.ANY
    val requiresWriteAccess =
      call.argument<Boolean>("requiresWriteAccess") ?: false
    val considerRawFile =
      call.argument<Boolean>("considerRawFile") ?: true

    if (documentType != null && documentTypeValue == null) {
      throwInvalidDocumentType(result, documentType)
    } else {
      result.success(
        createDocumentFileMap(
          DocumentFileCompat.fromFullPath(
            plugin.context,
            fullPath = fullPath,
            documentType = defaultDocumentTypeValue,
            requiresWriteAccess = requiresWriteAccess,
            considerRawFile = considerRawFile
          )
        )
      )
    }
  }

  private fun fromFile(call: MethodCall, result: MethodChannel.Result) {
    val file = File(call.argument<String>("file")!!)
    val documentType = call.argument<String>("documentType")
    val documentTypeValue = valueOf<DocumentFileType>(documentType)
    val defaultDocumentTypeValue = documentTypeValue ?: DocumentFileType.ANY
    val requiresWriteAccess =
      call.argument<Boolean>("requiresWriteAccess") ?: false
    val considerRawFile =
      call.argument<Boolean>("considerRawFile") ?: true

    if (documentType != null && documentTypeValue == null) {
      throwInvalidDocumentType(result, documentType)
    } else {
      result.success(
        createDocumentFileMap(
          DocumentFileCompat.fromFile(
            plugin.context,
            file = file,
            documentType = defaultDocumentTypeValue,
            requiresWriteAccess = requiresWriteAccess,
            considerRawFile = considerRawFile
          )
        )
      )
    }
  }

  private fun throwInvalidDocumentType(
    result: MethodChannel.Result,
    documentType: String
  ) {
    result.error(
      EXCEPTION_INVALID_DOCUMENT_TYPE,
      "You must provide a valid Document Type or null: ${
        DocumentFileType.values().joinToString()
      }, got $documentType",
      documentType
    )
  }

  @RequiresApi(API_19)
  override fun onActivityResult(
    requestCode: Int,
    resultCode: Int,
    data: Intent?
  ): Boolean {
    when (requestCode) {
      // TODO(@lakscastro): Implementation
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
      // TODO(@lakscastro): Implementation
    }
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }
}
