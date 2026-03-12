import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/utils/error_message_helper.dart';
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
      if (ErrorMessageHelper.isCancellation(errorString)) {
        return const Left(
          CancellationFailure(message: 'User cancelled Google sign-in'),
        );
      }

      // Get user-friendly error message
      final message = ErrorMessageHelper.getOAuthErrorMessage(errorString, 'Google');
      return Left(AuthFailure(message: message));
    }
  }

  /// Legacy method - calls execute()
  Future<Either<Failure, void>> call() => execute();
}
