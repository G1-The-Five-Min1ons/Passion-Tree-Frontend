/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  AppException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'AppException [$statusCode]: $message';
    }
    return 'AppException: $message';
  }
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'NetworkException [$statusCode]: $message';
    }
    return 'NetworkException: $message';
  }
}

/// Timeout exception
class TimeoutException extends AppException {
  TimeoutException({
    super.message = 'Request timeout',
    super.originalError,
  });

  @override
  String toString() => 'TimeoutException: $message';
}

/// Authentication exceptions
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.statusCode,
    super.originalError,
  });

  factory AuthException.unauthorized({String? message}) {
    return AuthException(
      message: message ?? 'Unauthorized access',
      statusCode: 401,
    );
  }

  factory AuthException.forbidden({String? message}) {
    return AuthException(
      message: message ?? 'Access forbidden',
      statusCode: 403,
    );
  }

  factory AuthException.tokenExpired() {
    return AuthException(
      message: 'Authentication token has expired',
      statusCode: 401,
    );
  }

  @override
  String toString() {
    if (statusCode != null) {
      return 'AuthException [$statusCode]: $message';
    }
    return 'AuthException: $message';
  }
}

/// Server-side exceptions
class ServerException extends AppException {
  ServerException({
    required super.message,
    super.statusCode,
    super.originalError,
  });

  factory ServerException.internalError({String? message}) {
    return ServerException(
      message: message ?? 'Internal server error',
      statusCode: 500,
    );
  }

  factory ServerException.badGateway({String? message}) {
    return ServerException(
      message: message ?? 'Bad gateway',
      statusCode: 502,
    );
  }

  factory ServerException.serviceUnavailable({String? message}) {
    return ServerException(
      message: message ?? 'Service unavailable',
      statusCode: 503,
    );
  }

  @override
  String toString() {
    if (statusCode != null) {
      return 'ServerException [$statusCode]: $message';
    }
    return 'ServerException: $message';
  }
}

/// Client-side exceptions (4xx errors)
class ClientException extends AppException {
  ClientException({
    required super.message,
    super.statusCode,
    super.originalError,
  });

  factory ClientException.badRequest({String? message}) {
    return ClientException(
      message: message ?? 'Bad request',
      statusCode: 400,
    );
  }

  factory ClientException.notFound({String? message}) {
    return ClientException(
      message: message ?? 'Resource not found',
      statusCode: 404,
    );
  }

  factory ClientException.conflict({String? message}) {
    return ClientException(
      message: message ?? 'Conflict',
      statusCode: 409,
    );
  }

  factory ClientException.unprocessableEntity({String? message}) {
    return ClientException(
      message: message ?? 'Unprocessable entity',
      statusCode: 422,
    );
  }

  @override
  String toString() {
    if (statusCode != null) {
      return 'ClientException [$statusCode]: $message';
    }
    return 'ClientException: $message';
  }
}

/// Cache-related exceptions
class CacheException extends AppException {
  CacheException({
    required super.message,
    super.originalError,
  }) : super(statusCode: null);

  @override
  String toString() => 'CacheException: $message';
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  ValidationException({
    required super.message,
    this.fieldErrors,
    super.originalError,
  }) : super(statusCode: 422);

  @override
  String toString() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final errors = fieldErrors!.entries
          .map((e) => '${e.key}: ${e.value.join(", ")}')
          .join('; ');
      return 'ValidationException: $message ($errors)';
    }
    return 'ValidationException: $message';
  }
}

/// Parse exceptions
class ParseException extends AppException {
  ParseException({
    required super.message,
    super.originalError,
  }) : super(statusCode: null);

  @override
  String toString() => 'ParseException: $message';
}

/// Account reactivation required exception
class AccountReactivationRequiredException extends AppException {
  final int gracePeriodDays;

  AccountReactivationRequiredException({
    required super.message,
    this.gracePeriodDays = 14,
    super.originalError,
  }) : super(statusCode: 200);

  @override
  String toString() {
    return 'AccountReactivationRequiredException: $message (Grace period: $gracePeriodDays days)';
  }
}

/// Helper function to create exception from status code
AppException createExceptionFromStatusCode(int statusCode, String message) {
  if (statusCode >= 500) {
    return ServerException(message: message, statusCode: statusCode);
  } else if (statusCode == 401 || statusCode == 403) {
    return AuthException(message: message, statusCode: statusCode);
  } else if (statusCode >= 400) {
    return ClientException(message: message, statusCode: statusCode);
  } else {
    return NetworkException(message: message, statusCode: statusCode);
  }
}
