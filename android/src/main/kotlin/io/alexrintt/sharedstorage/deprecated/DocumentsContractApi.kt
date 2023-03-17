package io.alexrintt.sharedstorage.deprecated

import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Point
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.util.Log
import io.alexrintt.sharedstorage.ROOT_CHANNEL
import io.alexrintt.sharedstorage.SharedStoragePlugin
import io.alexrintt.sharedstorage.deprecated.lib.GET_DOCUMENT_THUMBNAIL
import io.alexrintt.sharedstorage.utils.API_21
import io.alexrintt.sharedstorage.utils.ActivityListener
import io.alexrintt.sharedstorage.utils.Listenable
import io.alexrintt.sharedstorage.utils.notSupported
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.nio.ByteBuffer
import java.util.*

const val APK_MIME_TYPE = "application/vnd.android.package-archive"

internal class DocumentsContractApi(private val plugin: SharedStoragePlugin) :
  MethodChannel.MethodCallHandler, Listenable, ActivityListener {
  private var channel: MethodChannel? = null

  companion object {
    private const val CHANNEL = "documentscontract"
  }

  private fun createTempUriFile(sourceUri: Uri, callback: (File) -> Unit) {
    val destinationFilename: String = UUID.randomUUID().toString()

    val tempDestinationFile =
      File(plugin.context.cacheDir.path, destinationFilename)

    plugin.context.contentResolver.openInputStream(sourceUri)?.use {
      createFileFromStream(it, tempDestinationFile)
    }

    callback(tempDestinationFile)
  }

  private fun createFileFromStream(ins: InputStream, destination: File?) {
    FileOutputStream(destination).use { fileOutputStream ->
      val buffer = ByteArray(4096)
      var length: Int
      while (ins.read(buffer).also { length = it } > 0) {
        fileOutputStream.write(buffer, 0, length)
      }
      fileOutputStream.flush()
    }
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      GET_DOCUMENT_THUMBNAIL -> {
        val uri = Uri.parse(call.argument("uri"))
        val mimeType: String? = plugin.context.contentResolver.getType(uri)

        if (mimeType == APK_MIME_TYPE) {
          CoroutineScope(Dispatchers.IO).launch {
            createTempUriFile(uri) {
              val packageManager: PackageManager = plugin.context.packageManager
              val packageInfo: PackageInfo? =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                  packageManager.getPackageArchiveInfo(
                    it.path,
                    PackageManager.PackageInfoFlags.of(0)
                  )
                } else {
                  @Suppress("DEPRECATION")
                  packageManager.getPackageArchiveInfo(
                    it.path,
                    0
                  )
                }

              if (packageInfo == null) {
                if (it.exists()) it.delete()
                return@createTempUriFile result.success(null)
              }

              // the secret are these two lines....
              packageInfo.applicationInfo.sourceDir = it.path
              packageInfo.applicationInfo.publicSourceDir = it.path

              val apkIcon: Drawable =
                packageInfo.applicationInfo.loadIcon(packageManager)

              val bitmap: Bitmap = drawableToBitmap(apkIcon)

              val bytes: ByteArray = bitmap.convertToByteArray()

              val data =
                mapOf(
                  "bytes" to bytes,
                  "uri" to "$uri",
                  "width" to bitmap.width,
                  "height" to bitmap.height,
                  "byteCount" to bitmap.byteCount,
                  "density" to bitmap.density
                )

              if (it.exists()) it.delete()

              launch(Dispatchers.Main) { result.success(data) }
            }
          }
        } else {
          if (Build.VERSION.SDK_INT >= API_21) {
            getThumbnailForApi24(call, result)
          } else {
            result.notSupported(call.method, API_21)
          }
        }
      }
    }
  }

  private fun getThumbnailForApi24(
    call: MethodCall,
    result: MethodChannel.Result
  ) {
    CoroutineScope(Dispatchers.IO).launch {
      val uri = Uri.parse(call.argument("uri"))
      val width = call.argument<Int>("width")!!
      val height = call.argument<Int>("height")!!

      // run catching because [DocumentsContract.getDocumentThumbnail]
      // can throw a [FileNotFoundException].
      kotlin.runCatching {
        val bitmap = DocumentsContract.getDocumentThumbnail(
          plugin.context.contentResolver,
          uri,
          Point(width, height),
          null
        )

        if (bitmap != null) {
          val byteArray: ByteArray = bitmap.convertToByteArray()

          val data =
            mapOf(
              "bytes" to byteArray,
              "uri" to "$uri",
              "width" to bitmap.width,
              "height" to bitmap.height,
              "byteCount" to bitmap.byteCount,
              "density" to bitmap.density
            )

          launch(Dispatchers.Main) { result.success(data) }
        } else {
          Log.d("GET_DOCUMENT_THUMBNAIL", "bitmap is null")
          launch(Dispatchers.Main) { result.success(null) }
        }
      }
    }
  }

  override fun startListening(binaryMessenger: BinaryMessenger) {
    if (channel != null) stopListening()

    channel = MethodChannel(binaryMessenger, "$ROOT_CHANNEL/$CHANNEL")
    channel?.setMethodCallHandler(this)
  }

  override fun stopListening() {
    if (channel == null) return

    channel?.setMethodCallHandler(null)
    channel = null
  }

  override fun startListeningToActivity() {
    /** Implement if needed */
  }

  override fun stopListeningToActivity() {
    /** Implement if needed */
  }
}

fun drawableToBitmap(drawable: Drawable): Bitmap {
  if (drawable is BitmapDrawable) {
    val bitmapDrawable: BitmapDrawable = drawable
    if (bitmapDrawable.bitmap != null) {
      return bitmapDrawable.bitmap
    }
  }
  val bitmap: Bitmap =
    if (drawable.intrinsicWidth <= 0 || drawable.intrinsicHeight <= 0) {
      Bitmap.createBitmap(
        1,
        1,
        Bitmap.Config.ARGB_8888
      ) // Single color bitmap will be created of 1x1 pixel
    } else {
      Bitmap.createBitmap(
        drawable.intrinsicWidth,
        drawable.intrinsicHeight,
        Bitmap.Config.ARGB_8888
      )
    }
  val canvas = Canvas(bitmap)
  drawable.setBounds(0, 0, canvas.width, canvas.height)
  drawable.draw(canvas)
  return bitmap
}

/**
 * Convert bitmap to byte array using ByteBuffer.
 */
fun Bitmap.convertToByteArray(): ByteArray {
  //minimum number of bytes that can be used to store this bitmap's pixels
  val size: Int = this.byteCount

  //allocate new instances which will hold bitmap
  val buffer = ByteBuffer.allocate(size)
  val bytes = ByteArray(size)

  // copy the bitmap's pixels into the specified buffer
  this.copyPixelsToBuffer(buffer)

  // rewinds buffer (buffer position is set to zero and the mark is discarded)
  buffer.rewind()

  // transfer bytes from buffer into the given destination array
  buffer.get(bytes)

  // return bitmap's pixels
  return bytes
}
