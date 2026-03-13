import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/error/failure_mapper.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class ResendVerificationEmailUseCase {
  final IAuthRepository _repository;

  ResendVerificationEmailUseCase(this._repository);

  Future<Either<Failure, void>> execute(String email) async {
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      return left(
        const ValidationFailure(message: 'Email is required to resend the verification code'),
      );
    }

    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(normalizedEmail)) {
      return left(
        const ValidationFailure(message: 'Please enter a valid email address'),
      );
    }

    try {
      await _repository.resendVerificationEmail(normalizedEmail);
      return right(null);
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }
}