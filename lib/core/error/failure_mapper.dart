import 'exceptions.dart';
import 'failures.dart';

/// Converts exceptions to user-friendly failures
class FailureMapper {
  /// Convert any exception to a Failure
  static Failure fromException(dynamic exception) {
    if (exception is NetworkException) {
      return NetworkFailure(
        technicalMessage: exception.toString(),
      );
    }

    if (exception is TimeoutException) {
      return const TimeoutFailure();
    }

    if (exception is AuthException) {
      return _mapAuthException(exception);
    }

    if (exception is ServerException) {
      if (exception.statusCode == 503) {
        return ServerFailure.maintenance(
          technicalMessage: exception.toString(),
        );
      }
      return ServerFailure(
        technicalMessage: exception.toString(),
      );
    }

    if (exception is ClientException) {
      return _mapClientException(exception);
    }

    if (exception is ValidationException) {
      return ValidationFailure(
        fieldErrors: exception.fieldErrors,
        technicalMessage: exception.toString(),
      );
    }

    if (exception is CacheException) {
      return CacheFailure(
        technicalMessage: exception.toString(),
      );
    }

    if (exception is ParseException) {
      return ParseFailure(
        technicalMessage: exception.toString(),
      );
    }

    // Unknown exception
    return UnknownFailure(
      technicalMessage: exception.toString(),
    );
  }

  /// Map authentication exceptions
  static Failure _mapAuthException(AuthException exception) {
    switch (exception.statusCode) {
      case 401:
        if (exception.message.toLowerCase().contains('expired')) {
          return AuthFailure.tokenExpired(
            technicalMessage: exception.toString(),
          );
        }
        if (exception.message.toLowerCase().contains('invalid') ||
            exception.message.toLowerCase().contains('incorrect') ||
            exception.message.toLowerCase().contains('wrong')) {
          return AuthFailure.invalidCredentials(
            technicalMessage: exception.toString(),
          );
        }
        return AuthFailure.unauthorized(
          technicalMessage: exception.toString(),
        );
      case 403:
        return AuthFailure.forbidden(
          technicalMessage: exception.toString(),
        );
      default:
        return AuthFailure(
          technicalMessage: exception.toString(),
        );
    }
  }

  /// Map client-side exceptions
  static Failure _mapClientException(ClientException exception) {
    switch (exception.statusCode) {
      case 400:
        return BadRequestFailure(
          technicalMessage: exception.toString(),
        );
      case 404:
        return NotFoundFailure(
          technicalMessage: exception.toString(),
        );
      case 409:
        return ConflictFailure(
          technicalMessage: exception.toString(),
        );
      case 422:
        return ValidationFailure(
          technicalMessage: exception.toString(),
        );
      default:
        return BadRequestFailure(
          technicalMessage: exception.toString(),
        );
    }
  }
}
