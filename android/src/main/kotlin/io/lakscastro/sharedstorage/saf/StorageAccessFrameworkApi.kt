package io.lakscastro.sharedstorage.saf

import io.flutter.plugin.common.*
import io.lakscastro.sharedstorage.SharedStoragePlugin
import io.lakscastro.sharedstorage.plugin.ActivityListener
import io.lakscastro.sharedstorage.plugin.Listenable

class StorageAccessFramework(plugin: SharedStoragePlugin) :
  Listenable,
  ActivityListener {
  private val documentFileApi = DocumentFileApi(plugin)
  private val documentsContractApi = DocumentsContractApi(plugin)

  override fun startListening(binaryMessenger: BinaryMessenger) {
    documentFileApi.startListening(binaryMessenger)
    documentsContractApi.startListening(binaryMessenger)
  }

  override fun stopListening() {
    documentFileApi.stopListening()
    documentsContractApi.stopListening()
  }

  override fun startListeningToActivity() {
    documentFileApi.startListeningToActivity()
    documentsContractApi.startListeningToActivity()
  }

  override fun stopListeningToActivity() {
    documentFileApi.stopListeningToActivity()
    documentsContractApi.stopListeningToActivity()
  }
}
