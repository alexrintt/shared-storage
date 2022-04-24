package io.lakscastro.sharedstorage.simplestorage

import io.flutter.plugin.common.*
import io.lakscastro.sharedstorage.SharedStoragePlugin
import io.lakscastro.sharedstorage.plugin.ActivityListener
import io.lakscastro.sharedstorage.plugin.Listenable

class SimpleStorageApi(plugin: SharedStoragePlugin) :
  Listenable,
  ActivityListener {
  private val documentFileCompatApi = DocumentFileCompatApi(plugin)

  override fun startListening(binaryMessenger: BinaryMessenger) {
    documentFileCompatApi.startListening(binaryMessenger)
  }

  override fun stopListening() {
    documentFileCompatApi.stopListening()
  }

  override fun startListeningToActivity() {
    documentFileCompatApi.startListeningToActivity()
  }

  override fun stopListeningToActivity() {
    documentFileCompatApi.stopListeningToActivity()
  }
}
