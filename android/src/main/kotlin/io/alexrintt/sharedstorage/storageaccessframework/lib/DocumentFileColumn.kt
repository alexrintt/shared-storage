package io.alexrintt.sharedstorage.deprecated.lib

import android.database.Cursor
import android.provider.DocumentsContract
import java.lang.NullPointerException

private const val PREFIX = "DocumentFileColumn"

enum class DocumentFileColumnType {
  LONG,
  STRING,
  INT
}


fun getDocumentsContractColumns(): List<String> {
  return listOf(
    DocumentsContract.Document.COLUMN_DOCUMENT_ID,
    DocumentsContract.Document.COLUMN_DISPLAY_NAME,
    DocumentsContract.Document.COLUMN_MIME_TYPE,
    DocumentsContract.Document.COLUMN_SIZE,
    DocumentsContract.Document.COLUMN_SUMMARY,
    DocumentsContract.Document.COLUMN_LAST_MODIFIED,
  )
}

/// `column` must be a constant String from `DocumentsContract.Document.COLUMN*`
fun typeOfColumn(column: String): DocumentFileColumnType? {
  val values = mapOf(
    DocumentsContract.Document.COLUMN_DOCUMENT_ID to DocumentFileColumnType.STRING,
    DocumentsContract.Document.COLUMN_DISPLAY_NAME to DocumentFileColumnType.STRING,
    DocumentsContract.Document.COLUMN_MIME_TYPE to DocumentFileColumnType.STRING,
    DocumentsContract.Document.COLUMN_SIZE to DocumentFileColumnType.LONG,
    DocumentsContract.Document.COLUMN_SUMMARY to DocumentFileColumnType.STRING,
    DocumentsContract.Document.COLUMN_LAST_MODIFIED to DocumentFileColumnType.LONG,
    DocumentsContract.Document.COLUMN_FLAGS to DocumentFileColumnType.INT
  )

  return values[column]
}

fun cursorHandlerOf(type: DocumentFileColumnType): (Cursor, Int) -> Any? {
  when (type) {
    DocumentFileColumnType.LONG -> {
      return { cursor, index ->
        try {
          cursor.getLong(index)
        } catch (e: NullPointerException) {
          null
        }
      }
    }

    DocumentFileColumnType.STRING -> {
      return { cursor, index ->
        try {
          cursor.getString(index)
        } catch (e: NullPointerException) {
          null
        }
      }
    }

    DocumentFileColumnType.INT -> {
      return { cursor, index ->
        try {
          cursor.getInt(index)
        } catch (e: NullPointerException) {
          null
        }
      }
    }
  }
}
