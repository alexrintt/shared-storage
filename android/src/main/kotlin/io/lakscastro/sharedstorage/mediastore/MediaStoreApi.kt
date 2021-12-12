package io.lakscastro.sharedstorage.mediastore

import android.os.Build
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.lakscastro.sharedstorage.ROOT_CHANNEL
import io.lakscastro.sharedstorage.SharedStoragePlugin
import io.lakscastro.sharedstorage.plugin.Listenable

class MediaStoreApi(val plugin: SharedStoragePlugin) : MethodChannel.MethodCallHandler, Listenable {
  private var channel: MethodChannel? = null

  companion object {
    private const val GET_MEDIA_STORE_CONTENT_DIRECTORY = "getMediaStoreContentDirectory"
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      GET_MEDIA_STORE_CONTENT_DIRECTORY ->
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
          getMediaStoreContentDirectory(
            result,
            call.argument<String?>("collection") as String
          )
        } else {
          result.notImplemented()
        }
      else -> result.notImplemented()
    }
  }

  @RequiresApi(Build.VERSION_CODES.Q)
  private fun getMediaStoreContentDirectory(
    result: MethodChannel.Result,
    collection: String
  ) = result.success(mediaStoreOf(collection))

  /// Returns the [EXTERNAL_CONTENT_URI] of [MediaStore.<MEDIA>] equivalent to [collection]
  @RequiresApi(Build.VERSION_CODES.Q)
  fun mediaStoreOf(collection: String): String? {
    val mapper = mapOf(
      "MediaStoreCollection.Downloads" to MediaStore.Downloads.EXTERNAL_CONTENT_URI.path,
      "MediaStoreCollection.Audio" to MediaStore.Audio.Media.EXTERNAL_CONTENT_URI.path,
      "MediaStoreCollection.Video" to MediaStore.Video.Media.EXTERNAL_CONTENT_URI.path,
      "MediaStoreCollection.Images" to MediaStore.Images.Media.EXTERNAL_CONTENT_URI.path
    )

    return mapper[collection]
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