package io.lakscastro.sharedstorage

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Context
import android.os.Build
import android.os.Environment
import androidx.annotation.RequiresApi

/** SharedStoragePlugin */
class SharedStoragePlugin : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  companion object {
    const val METHOD_CHANNEL_NAME = "io.lakscastro.plugins/sharedstorage"

    const val GET_EXTERNAL_STORAGE_PUBLIC_DIRECTORY = "getExternalStoragePublicDirectory"
    const val GET_EXTERNAL_STORAGE_DIRECTORY = "getExternalStorageDirectory"

    const val GET_MEDIA_STORE_CONTENT_DIRECTORY = "getMediaStoreContentDirectory"
    const val GET_ROOT_DIRECTORY = "getRootDirectory"
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      GET_EXTERNAL_STORAGE_PUBLIC_DIRECTORY -> getExternalStoragePublicDirectory(result, call.argument<String?>("directory") as String)
      GET_EXTERNAL_STORAGE_DIRECTORY -> getExternalStorageDirectory(result)
      GET_MEDIA_STORE_CONTENT_DIRECTORY -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) getMediaStoreContentDirectory(result, call.argument<String?>("collection") as String) else result.notImplemented()
      GET_ROOT_DIRECTORY -> getRootDirectory(result)
      else -> result.notImplemented()
    }
  }

  private fun getExternalStoragePublicDirectory(result: Result, directory: String) = result.success(environmentDirectoryOf(directory).absolutePath)

  private fun getExternalStorageDirectory(result: Result) = result.success(Environment.getExternalStorageDirectory().absolutePath)

  @RequiresApi(Build.VERSION_CODES.Q)
  private fun getMediaStoreContentDirectory(result: Result, collection: String) = result.success(mediaStoreOf(collection))

  private fun getRootDirectory(result: Result) = result.success(Environment.getRootDirectory().absolutePath)
}
