package io.alexrintt.sharedstorage.storageaccessframework

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
import io.alexrintt.sharedstorage.plugin.*
import io.alexrintt.sharedstorage.storageaccessframework.*
import io.alexrintt.sharedstorage.storageaccessframework.lib.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.InputStream
import java.io.Serializable
import java.util.*


const val APK_MIME_TYPE = "application/vnd.android.package-archive"

internal class DocumentsContractApi(private val plugin: SharedStoragePlugin) :
  MethodChannel.MethodCallHandler, Listenable, ActivityListener {
  private var channel: MethodChannel? = null

  companion object {
    private const val CHANNEL = "documentscontract"
  }

  private fun createTempUriFile(sourceUri: Uri, callback: (File?) -> Unit) {
    try {
      val destinationFilename: String = UUID.randomUUID().toString()

      val tempDestinationFile =
        File(plugin.context.cacheDir.path, destinationFilename)

      plugin.context.contentResolver.openInputStream(sourceUri)?.use {
        createFileFromStream(it, tempDestinationFile)
      }
      callback(tempDestinationFile)
    } catch (_: FileNotFoundException) {
      callback(null)
    }
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
          return result.success(null)
//          getThumbnailForApkFile(call, result, uri)
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

  private fun getThumbnailForApkFile(
    call: MethodCall,
    result: MethodChannel.Result,
    uri: Uri
  ) {
    CoroutineScope(Dispatchers.IO).launch {
      createTempUriFile(uri) {
        if (it == null) {
          launch(Dispatchers.Main) { result.success(null) }
          return@createTempUriFile
        }

        kotlin.runCatching {
          val packageManager: PackageManager =
            plugin.context.packageManager
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

          // Parse the apk and to get the icon later on
          packageInfo.applicationInfo.sourceDir = it.path
          packageInfo.applicationInfo.publicSourceDir = it.path

          val apkIcon: Drawable =
            packageInfo.applicationInfo.loadIcon(packageManager)

          val bitmap: Bitmap = drawableToBitmap(apkIcon)

          val data = bitmap.generateSerializableBitmapData(uri)

          if (it.exists()) it.delete()

          launch(Dispatchers.Main) { result.success(data) }
        }

        try {
        } catch (e: FileNotFoundException) {
          // The target file apk is invalid
          launch(Dispatchers.Main) { result.success(null) }
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
          val data = bitmap.generateSerializableBitmapData(uri)

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
 *
 * This method calls [Bitmap.recycle] so this function will make the bitmap unusable after that.
 */
fun Bitmap.convertToByteArray(): ByteArray {
  val stream = ByteArrayOutputStream()

  // Very important, see https://stackoverflow.com/questions/51516310/sending-bitmap-to-flutter-from-android-platform
  // Without compressing the raw bitmap, Flutter Image widget cannot decode it correctly and will throw a error.
  this.compress(Bitmap.CompressFormat.PNG, 100, stream)

  val byteArray = stream.toByteArray()

  this.recycle()

  return byteArray
}

fun Bitmap.generateSerializableBitmapData(
  uri: Uri,
  additional: Map<String, Serializable> = mapOf()
): Map<String, Serializable> {
  val metadata = mapOf(
    "uri" to "$uri",
    "width" to this.width,
    "height" to this.height,
    "byteCount" to this.byteCount,
    "density" to this.density
  )

  val bytes: ByteArray = this.convertToByteArray()

  return metadata + additional + mapOf<String, Serializable>(
    "bytes" to bytes
  )
}
