import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/error/failure_mapper.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final IAuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<Either<Failure, void>> execute({
    required String oldPassword,
    required String newPassword,
  }) async {
    // Validation logic
    if (oldPassword.isEmpty) {
      return left(const ValidationFailure(message: 'Current password cannot be empty'));
    }

    if (newPassword.isEmpty) {
      return left(const ValidationFailure(message: 'New password cannot be empty'));
    }

    if (newPassword.length < 8) {
      return left(const ValidationFailure(message: 'New password must be at least 8 characters'));
    }

    if (oldPassword == newPassword) {
      return left(const ValidationFailure(message: 'New password must be different from current password'));
    }

    // Call repository and handle exceptions
    try {
      await _repository.changePassword(oldPassword, newPassword);
      return right(null);
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }
}
