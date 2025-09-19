/// Enumeration for different types of API errors
enum ApiErrorType {
  network,
  timeout,
  server,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  validation,
  cancelled,
  unknown,
}

/// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final ApiErrorType type;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const ApiException(
    this.message,
    this.type, {
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException: $message (Type: $type, Status: $statusCode)';
  }

  /// Get user-friendly error message
  String get userMessage {
    switch (type) {
      case ApiErrorType.network:
        return 'Please check your internet connection and try again.';
      case ApiErrorType.timeout:
        return 'Request timed out. Please try again.';
      case ApiErrorType.server:
        return 'Server error occurred. Please try again later.';
      case ApiErrorType.badRequest:
        return message.isNotEmpty ? message : 'Invalid request.';
      case ApiErrorType.unauthorized:
        return 'Please log in to continue.';
      case ApiErrorType.forbidden:
        return 'You don\'t have permission to perform this action.';
      case ApiErrorType.notFound:
        return 'The requested resource was not found.';
      case ApiErrorType.validation:
        return message.isNotEmpty ? message : 'Please check your input and try again.';
      case ApiErrorType.cancelled:
        return 'Request was cancelled.';
      case ApiErrorType.unknown:
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Check if error is retryable
  bool get isRetryable {
    switch (type) {
      case ApiErrorType.network:
      case ApiErrorType.timeout:
      case ApiErrorType.server:
        return true;
      case ApiErrorType.badRequest:
      case ApiErrorType.unauthorized:
      case ApiErrorType.forbidden:
      case ApiErrorType.notFound:
      case ApiErrorType.validation:
      case ApiErrorType.cancelled:
      case ApiErrorType.unknown:
      default:
        return false;
    }
  }

  /// Check if error requires authentication
  bool get requiresAuth {
    return type == ApiErrorType.unauthorized;
  }
}

/// Exception for sync-related errors
class SyncException extends ApiException {
  final String? entityId;
  final String? entityType;
  final DateTime? lastSyncAt;

  const SyncException(
    String message,
    ApiErrorType type, {
    this.entityId,
    this.entityType,
    this.lastSyncAt,
    int? statusCode,
    Map<String, dynamic>? details,
  }) : super(message, type, statusCode: statusCode, details: details);

  @override
  String toString() {
    return 'SyncException: $message (Entity: $entityType:$entityId, Type: $type)';
  }
}

/// Exception for database-related errors
class DatabaseException extends ApiException {
  final String? query;
  final String? table;

  const DatabaseException(
    String message,
    ApiErrorType type, {
    this.query,
    this.table,
    int? statusCode,
    Map<String, dynamic>? details,
  }) : super(message, type, statusCode: statusCode, details: details);

  @override
  String toString() {
    return 'DatabaseException: $message (Table: $table, Type: $type)';
  }
}

/// Exception for validation errors with field-specific details
class ValidationException extends ApiException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException(
    String message,
    this.fieldErrors, {
    int? statusCode,
    Map<String, dynamic>? details,
  }) : super(message, ApiErrorType.validation, statusCode: statusCode, details: details);

  /// Get errors for a specific field
  List<String> getFieldErrors(String field) {
    return fieldErrors[field] ?? [];
  }

  /// Check if a specific field has errors
  bool hasFieldError(String field) {
    return fieldErrors.containsKey(field) && fieldErrors[field]!.isNotEmpty;
  }

  /// Get all error messages as a single string
  String get allErrorsMessage {
    final errors = <String>[];
    fieldErrors.forEach((field, fieldErrors) {
      for (final error in fieldErrors) {
        errors.add('$field: $error');
      }
    });
    return errors.join('\n');
  }

  @override
  String toString() {
    return 'ValidationException: $message\nField errors: $fieldErrors';
  }
}