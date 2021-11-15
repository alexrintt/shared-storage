package io.lakscastro.sharedstorage

import android.os.Build
import android.provider.MediaStore
import androidx.annotation.RequiresApi

/// Returns the [EXTERNAL_CONTENT_URI] of [MediaStore.<MEDIA>] equivalent to [collection]
@RequiresApi(Build.VERSION_CODES.Q)
fun mediaStoreOf(collection: String): String? {
  val mapper = mapOf(
    "MediaStoreCollection.Downloads" to MediaStore.Downloads.EXTERNAL_CONTENT_URI.path,
    "MediaStoreCollection.Audio" to MediaStore.Audio.Media.EXTERNAL_CONTENT_URI.path,
    "MediaStoreCollection.Video" to MediaStore.Video.Media.EXTERNAL_CONTENT_URI.path,
    "MediaStoreCollection.Images" to MediaStore.Images.Media.EXTERNAL_CONTENT_URI.path
  )

  return mapper[collection]
}