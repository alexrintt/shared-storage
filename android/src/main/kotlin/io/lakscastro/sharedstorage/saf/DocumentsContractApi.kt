package io.lakscastro.sharedstorage.saf

import android.graphics.Point
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.lakscastro.sharedstorage.ROOT_CHANNEL
import io.lakscastro.sharedstorage.SharedStoragePlugin
import io.lakscastro.sharedstorage.plugin.ActivityListener
import io.lakscastro.sharedstorage.plugin.Listenable
import io.lakscastro.sharedstorage.saf.utils.*

internal class DocumentsContractApi(private val plugin: SharedStoragePlugin) :
  MethodChannel.MethodCallHandler,
  Listenable,
  ActivityListener {
  private val pendingResults: MutableMap<Int, MethodChannel.Result> =
    mutableMapOf()
  private var channel: MethodChannel? = null
  private var eventChannel: EventChannel? = null
  private var eventSink: EventChannel.EventSink? = null

  companion object {
    private const val CHANNEL = "documentscontract"
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      GET_DOCUMENT_THUMBNAIL -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          val uri = Uri.parse(call.argument("uri"))
          val width = call.argument<Int>("width")!!
          val height = call.argument<Int>("height")!!

          DocumentsContract.getDocumentThumbnail(
            plugin.context.contentResolver,
            uri,
            Point(width, height),
            null
          )
        }
      }
    }
  }

  override fun startListening(binaryMessenger: BinaryMessenger) {
    if (channel != null) stopListening()

    channel = MethodChannel(binaryMessenger, "$ROOT_CHANNEL/$CHANNEL")
    channel?.setMethodCallHandler(this)
  }

  override fun stopListening() {
    if (channel == null) return

    channel?.setMethodCallHandler(null)
    channel = null

    eventChannel?.setStreamHandler(null)
    eventChannel = null
  }

  override fun startListeningToActivity() {
    /// Implement if needed
  }

  override fun stopListeningToActivity() {
    /// Implement if needed
  }
}
