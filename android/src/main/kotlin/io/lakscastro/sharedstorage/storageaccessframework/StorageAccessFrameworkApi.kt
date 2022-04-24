package io.lakscastro.sharedstorage.storageaccessframework

import io.flutter.plugin.common.*
import io.lakscastro.sharedstorage.SharedStoragePlugin
import io.lakscastro.sharedstorage.plugin.ActivityListener
import io.lakscastro.sharedstorage.plugin.Listenable

class StorageAccessFrameworkApi(plugin: SharedStoragePlugin) :
  Listenable,
  ActivityListener {
  private val documentFileApi = DocumentFileApi(plugin)
  private val documentsContractApi = DocumentsContractApi(plugin)
  private val documentFileHelperApi = DocumentFileHelperApi(plugin)

  override fun startListening(binaryMessenger: BinaryMessenger) {
    documentFileApi.startListening(binaryMessenger)
    documentsContractApi.startListening(binaryMessenger)
    documentFileHelperApi.startListening(binaryMessenger)
  }

  override fun stopListening() {
    documentFileApi.stopListening()
    documentsContractApi.stopListening()
    documentFileHelperApi.stopListening()
  }

  override fun startListeningToActivity() {
    documentFileApi.startListeningToActivity()
    documentsContractApi.startListeningToActivity()
    documentFileHelperApi.startListeningToActivity()
  }

  override fun stopListeningToActivity() {
    documentFileApi.stopListeningToActivity()
    documentsContractApi.stopListeningToActivity()
    documentFileHelperApi.stopListeningToActivity()
  }
}
