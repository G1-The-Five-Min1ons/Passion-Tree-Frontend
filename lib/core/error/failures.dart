import 'package:equatable/equatable.dart';

/// Base failure class for the application
/// Failures represent app-level errors that are shown to users
abstract class Failure extends Equatable {
  final String message;
  final String? technicalMessage;

  const Failure({
    required this.message,
    this.technicalMessage,
  });

  @override
  List<Object?> get props => [message, technicalMessage];

  @override
  String toString() => message;
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.technicalMessage,
  });
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Connection timed out. Please try again.',
    super.technicalMessage,
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed.',
    super.technicalMessage,
  });

  const AuthFailure.unauthorized({
    super.message = 'Session expired. Please log in again.',
    String? technicalMessage,
  });

  const AuthFailure.forbidden({
    super.message = 'You do not have permission to access this resource.',
    String? technicalMessage,
  });

  const AuthFailure.tokenExpired({
    super.message = 'Your session has expired. Please re-authenticate.',
    String? technicalMessage,
  });

  const AuthFailure.invalidCredentials({
    super.message = 'Invalid email or password.',
    String? technicalMessage,
  });
}

/// Server failures
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Internal server error. Please try again later.',
    super.technicalMessage,
  });

  const ServerFailure.maintenance({
    super.message = 'Server is under maintenance. Please try again later.',
    String? technicalMessage,
  });
}

/// Data not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested information was not found.',
    super.technicalMessage,
  });
}

/// Bad request failures
class BadRequestFailure extends Failure {
  const BadRequestFailure({
    super.message = 'Invalid request. Please check your input.',
    super.technicalMessage,
  });
}

/// Conflict failures (e.g., duplicate data)
class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message = 'This data already exists in the system.',
    super.technicalMessage,
  });
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    super.message = 'Validation failed. Please correct the errors.',
    this.fieldErrors,
    super.technicalMessage,
  });

  @override
  List<Object?> get props => [message, technicalMessage, fieldErrors];

  /// Get error message for a specific field
  String? getFieldError(String fieldName) {
    final errors = fieldErrors?[fieldName];
    return errors?.isNotEmpty == true ? errors!.first : null;
  }

  /// Get all error messages for a specific field
  List<String>? getFieldErrors(String fieldName) {
    return fieldErrors?[fieldName];
  }

  /// Check if a specific field has errors
  bool hasFieldError(String fieldName) {
    return fieldErrors?.containsKey(fieldName) == true;
  }
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to load cached data.',
    super.technicalMessage,
  });
}

/// Parse/Data format failures
class ParseFailure extends Failure {
  const ParseFailure({
    super.message = 'Error parsing data format.',
    super.technicalMessage,
  });
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Application requires additional permissions.',
    super.technicalMessage,
  });
}

/// Unknown/Unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.technicalMessage,
  });
}
