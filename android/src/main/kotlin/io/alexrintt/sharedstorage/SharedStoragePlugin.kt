package io.alexrintt.sharedstorage

import android.content.Context
import io.alexrintt.sharedstorage.deprecated.StorageAccessFrameworkApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

const val ROOT_CHANNEL = "io.alexrintt.plugins/sharedstorage"

/** Flutter plugin Kotlin implementation `SharedStoragePlugin` */
class SharedStoragePlugin : FlutterPlugin, ActivityAware {
  /** `DocumentFile` API channel */
  private val storageAccessFrameworkApi = StorageAccessFrameworkApi(this)

  lateinit var context: Context
  var binding: ActivityPluginBinding? = null

  /** Setup all APIs */
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext

    storageAccessFrameworkApi.startListening(flutterPluginBinding.binaryMessenger)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.binding = binding

    storageAccessFrameworkApi.startListeningToActivity()
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    storageAccessFrameworkApi.stopListening()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    storageAccessFrameworkApi.stopListeningToActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.binding = binding
  }

  override fun onDetachedFromActivity() {
    binding = null
  }
}
