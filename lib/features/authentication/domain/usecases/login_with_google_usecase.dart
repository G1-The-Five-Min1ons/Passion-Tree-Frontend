import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

/// Use case for Google OAuth login using google_sign_in package
class LoginWithGoogleUseCase {
  final IAuthRepository _repository;

  LoginWithGoogleUseCase(this._repository);

  /// Execute Google Sign-In flow
  /// Returns Either<Failure, void> - Left on failure, Right on success
  Future<Either<Failure, void>> execute() async {
    try {
      await _repository.signInWithGoogle();
      return const Right(null);
    } catch (e) {
      final errorString = e.toString();

      // Check for user cancellation
      if (errorString.contains('CANCELLED') ||
          errorString.contains('cancelled') ||
          errorString.contains('canceled') ||
          errorString.contains('sign_in_canceled')) {
        return const Left(
          CancellationFailure(message: 'User cancelled Google sign-in'),
        );
      }

      // Check for specific backend errors and clean them up for the UI
      if (errorString.contains('account with this email already exists')) {
        return const Left(
          AuthFailure(
            message:
                'An account with this email already exists. Please use web login to link accounts.',
          ),
        );
      }

      // Clean up generic AuthException prefix if present
      String cleanMessage = errorString;
      if (cleanMessage.startsWith('AuthException')) {
        // Find the actual message after the colon
        final colonIndex = cleanMessage.indexOf(':');
        if (colonIndex != -1 && colonIndex < cleanMessage.length - 1) {
          cleanMessage = cleanMessage.substring(colonIndex + 1).trim();
        }
      }

      return Left(AuthFailure(message: 'Google sign-in failed: $cleanMessage'));
    }
  }

  /// Legacy method - calls execute()
  Future<Either<Failure, void>> call() => execute();
}
