package io.lakscastro.sharedstorage

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.lakscastro.sharedstorage.plugin.SharedStorageApi

const val ROOT_CHANNEL = "io.lakscastro.plugins/sharedstorage"

/** Flutter plugin Kotlin implementation `SharedStoragePlugin` */
class SharedStoragePlugin : FlutterPlugin, ActivityAware {
  /** `DocumentFile` API channel */
  private val sharedStorageApi = SharedStorageApi(this)

  lateinit var context: Context
  var binding: ActivityPluginBinding? = null

  /** Setup all APIs */
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext

    sharedStorageApi.startListening(flutterPluginBinding.binaryMessenger)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.binding = binding

    sharedStorageApi.startListeningToActivity()
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
    sharedStorageApi.stopListening()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    sharedStorageApi.stopListeningToActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.binding = binding
  }

  override fun onDetachedFromActivity() {
    binding = null
  }
}
