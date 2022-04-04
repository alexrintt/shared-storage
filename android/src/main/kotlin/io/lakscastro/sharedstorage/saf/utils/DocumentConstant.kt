package io.lakscastro.sharedstorage.saf.utils

/**
 * Storage Access Framework Exceptions
 */
const val EXCEPTION_PARENT_DOCUMENT_MUST_BE_DIRECTORY =
  "EXCEPTION_PARENT_DOCUMENT_MUST_BE_DIRECTORY"
const val EXCEPTION_MISSING_PERMISSIONS = "EXCEPTION_MISSING_PERMISSIONS"

/**
 * Available Method Channel APIs
 */
const val OPEN_DOCUMENT_TREE = "openDocumentTree"
const val PERSISTED_URI_PERMISSIONS = "persistedUriPermissions"
const val RELEASE_PERSISTABLE_URI_PERMISSION = "releasePersistableUriPermission"
const val CREATE_FILE = "createFile"
const val FROM_TREE_URI = "fromTreeUri"
const val CAN_WRITE = "canWrite"
const val CAN_READ = "canRead"
const val RENAME_TO = "renameTo"
const val LENGTH = "length"
const val EXISTS = "exists"
const val PARENT_FILE = "parentFile"
const val CREATE_DIRECTORY = "createDirectory"
const val DELETE = "delete"
const val FIND_FILE = "findFile"
const val COPY = "copy"
const val LAST_MODIFIED = "lastModified"
const val GET_DOCUMENT_THUMBNAIL = "getDocumentThumbnail"
const val BUILD_DOCUMENT_URI_USING_TREE = "buildDocumentUriUsingTree"
const val BUILD_DOCUMENT_URI = "buildDocumentUri"
const val BUILD_TREE_DOCUMENT_URI = "buildTreeDocumentUri"

/**
 * Available Event Channels APIs
 */
const val LIST_FILES = "listFiles"
const val GET_DOCUMENT_CONTENT = "getDocumentContent"

/**
 * Intent Request Codes
 */
const val OPEN_DOCUMENT_TREE_CODE = 10
