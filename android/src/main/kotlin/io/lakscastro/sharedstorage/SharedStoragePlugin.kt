package io.lakscastro.sharedstorage

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.lakscastro.sharedstorage.environment.EnvironmentApi
import io.lakscastro.sharedstorage.mediastore.MediaStoreApi
import io.lakscastro.sharedstorage.saf.StorageAccessFramework

const val ROOT_CHANNEL = "io.lakscastro.plugins/sharedstorage"

/** SharedStoragePlugin */
class SharedStoragePlugin : FlutterPlugin, ActivityAware {
  /// `Environment` API channel
  private val environmentApi = EnvironmentApi(this)

  /// `MediaStore` API channel
  private val mediaStoreApi = MediaStoreApi(this)

  /// `DocumentFile` API channel
  private val storageAccessFrameworkApi = StorageAccessFramework(this)

  lateinit var context: Context
  var binding: ActivityPluginBinding? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext

    /// Setup `Environment` API
    environmentApi.startListening(flutterPluginBinding.binaryMessenger)

    /// Setup `MediaStore` API
    mediaStoreApi.startListening(flutterPluginBinding.binaryMessenger)

    /// Setup `StorageAccessFramework` API
    storageAccessFrameworkApi.startListening(flutterPluginBinding.binaryMessenger)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.binding = binding

    storageAccessFrameworkApi.startListeningToActivity()
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
    environmentApi.stopListening()
    mediaStoreApi.stopListening()
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
