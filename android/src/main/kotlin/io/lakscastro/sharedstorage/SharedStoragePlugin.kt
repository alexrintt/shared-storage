package io.lakscastro.sharedstorage

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.lakscastro.sharedstorage.environment.EnvironmentApi
import io.lakscastro.sharedstorage.mediastore.MediaStoreApi
import io.lakscastro.sharedstorage.simplestorage.SimpleStorageApi
import io.lakscastro.sharedstorage.storageaccessframework.StorageAccessFrameworkApi

const val ROOT_CHANNEL = "io.lakscastro.plugins/sharedstorage"

/** Flutter plugin Kotlin implementation `SharedStoragePlugin` */
class SharedStoragePlugin : FlutterPlugin, ActivityAware {
  /** `Environment` API channel */
  private val environmentApi = EnvironmentApi(this)

  /** `MediaStore` API channel */
  private val mediaStoreApi = MediaStoreApi(this)

  /** `DocumentFile` API channel */
  private val storageAccessFrameworkApi = StorageAccessFrameworkApi(this)

  /** `SimpleStorage` API channel */
  private val simpleStorageApi = SimpleStorageApi(this)

  lateinit var context: Context
  var binding: ActivityPluginBinding? = null

  /** Setup all APIs */
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext

    environmentApi.startListening(flutterPluginBinding.binaryMessenger)
    mediaStoreApi.startListening(flutterPluginBinding.binaryMessenger)
    storageAccessFrameworkApi.startListening(flutterPluginBinding.binaryMessenger)
    simpleStorageApi.startListening(flutterPluginBinding.binaryMessenger)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.binding = binding

    storageAccessFrameworkApi.startListeningToActivity()
    simpleStorageApi.startListeningToActivity()
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
    environmentApi.stopListening()
    mediaStoreApi.stopListening()
    storageAccessFrameworkApi.stopListening()
    simpleStorageApi.stopListening()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    storageAccessFrameworkApi.stopListeningToActivity()
    simpleStorageApi.stopListeningToActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.binding = binding
  }

  override fun onDetachedFromActivity() {
    binding = null
  }
}
