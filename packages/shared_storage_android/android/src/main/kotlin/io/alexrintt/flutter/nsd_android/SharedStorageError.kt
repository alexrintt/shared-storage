package io.alexrintt.flutter.shared_storage_android

import android.net.shared_storage.NsdManager
import java.lang.Error

internal fun getErrorCause(errorCode: Int): String {
    return when (errorCode) {
        NsdManager.FAILURE_ALREADY_ACTIVE -> ErrorCause.ALREADY_ACTIVE.code
        NsdManager.FAILURE_MAX_LIMIT -> ErrorCause.MAX_LIMIT.code
        else -> ErrorCause.INTERNAL_ERROR.code
    }
}

internal fun getErrorMessage(errorCode: Int): String {
    return when (errorCode) {
        NsdManager.FAILURE_ALREADY_ACTIVE -> "Operation already active"
        NsdManager.FAILURE_MAX_LIMIT -> "Maximum outstanding requests reached"
        else -> "Internal error"
    }
}

/**
 * @param code error cause code as defined by enum in shared_storage_platform_interface
 */
internal enum class ErrorCause(val code: String) {
    ILLEGAL_ARGUMENT("illegalArgument"),
    ALREADY_ACTIVE("alreadyActive"),
    MAX_LIMIT("maxLimit"),
    INTERNAL_ERROR("internalError"),
    SECURITY_ISSUE("securityIssue"),
}

internal class NsdError(val errorCause: ErrorCause, val errorMessage: String) :
    Error("$errorMessage (${errorCause.code})")