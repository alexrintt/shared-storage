package io.lakscastro.sharedstorage.plugin

import io.flutter.plugin.common.BinaryMessenger

interface Listenable {
  fun startListening(binaryMessenger: BinaryMessenger);
  fun stopListening();
}