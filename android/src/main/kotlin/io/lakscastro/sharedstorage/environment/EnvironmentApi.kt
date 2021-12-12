package io.lakscastro.sharedstorage.environment

import android.os.Environment
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.lakscastro.sharedstorage.ROOT_CHANNEL
import io.lakscastro.sharedstorage.SharedStoragePlugin
import io.lakscastro.sharedstorage.plugin.Listenable
import java.io.File

class EnvironmentApi(plugin: SharedStoragePlugin) : MethodChannel.MethodCallHandler,
  Listenable {
  private var channel: MethodChannel? = null

  companion object {
    const val GET_EXTERNAL_STORAGE_PUBLIC_DIRECTORY =
      "getExternalStoragePublicDirectory"

    const val GET_ROOT_DIRECTORY = "getRootDirectory"

    const val GET_EXTERNAL_STORAGE_DIRECTORY = "getExternalStorageDirectory"
  }


  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      GET_EXTERNAL_STORAGE_PUBLIC_DIRECTORY ->
        getExternalStoragePublicDirectory(
          result,
          call.argument<String?>("directory") as String
        )
      GET_EXTERNAL_STORAGE_DIRECTORY -> getExternalStorageDirectory(result)
      GET_ROOT_DIRECTORY -> getRootDirectory(result)
      else -> result.notImplemented()
    }
  }

  private fun getExternalStoragePublicDirectory(
    result: MethodChannel.Result,
    directory: String
  ) = result.success(environmentDirectoryOf(directory).absolutePath)

  private fun getExternalStorageDirectory(result: MethodChannel.Result) =
    result.success(Environment.getExternalStorageDirectory().absolutePath)

  private fun getRootDirectory(result: MethodChannel.Result) =
    result.success(Environment.getRootDirectory().absolutePath)

  private fun environmentDirectoryOf(directory: String): File {
    val mapper = mapOf(
      "EnvironmentDirectory.Alarms" to Environment.DIRECTORY_ALARMS,
      "EnvironmentDirectory.DCIM" to Environment.DIRECTORY_DCIM,
      "EnvironmentDirectory.Downloads" to Environment.DIRECTORY_DOWNLOADS,
      "EnvironmentDirectory.Movies" to Environment.DIRECTORY_MOVIES,
      "EnvironmentDirectory.Music" to Environment.DIRECTORY_MUSIC,
      "EnvironmentDirectory.Notifications" to Environment.DIRECTORY_NOTIFICATIONS,
      "EnvironmentDirectory.Pictures" to Environment.DIRECTORY_PICTURES,
      "EnvironmentDirectory.Podcasts" to Environment.DIRECTORY_PODCASTS,
      "EnvironmentDirectory.Ringtones" to Environment.DIRECTORY_RINGTONES
    )

    return Environment.getExternalStoragePublicDirectory(mapper[directory] ?: directory)
  }

  override fun startListening(binaryMessenger: BinaryMessenger) {
    if (channel != null) {
      stopListening()
    }

    channel = MethodChannel(binaryMessenger, "$ROOT_CHANNEL/environment")
    channel?.setMethodCallHandler(this)
  }

  override fun stopListening() {
    if (channel == null) return

    channel?.setMethodCallHandler(null)
    channel = null
  }
}