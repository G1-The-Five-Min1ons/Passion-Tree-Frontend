import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final IAuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String code,
    required String newPassword,
  }) async {
    // Validation
    if (code.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Reset code cannot be empty'));
    }

    if (newPassword.isEmpty) {
      return const Left(ValidationFailure(message: 'New password cannot be empty'));
    }

    if (newPassword.length < 8) {
      return const Left(ValidationFailure(message: 'Password must be at least 8 characters'));
    }

    try {
      await repository.resetPassword(code, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
