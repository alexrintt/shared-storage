package io.lakscastro.sharedstorage.plugin

interface ActivityListener {
  fun startListeningToActivity()
  fun stopListeningToActivity()
}