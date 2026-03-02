import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/error/failure_mapper.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final IAuthRepository _repository;

  VerifyEmailUseCase(this._repository);

  Future<Either<Failure, void>> execute(String code) async {
    if (code.trim().isEmpty) {
      return left(const ValidationFailure(message: 'Verification code cannot be empty'));
    }

    if (code.trim().length != 6) {
      return left(const ValidationFailure(message: 'Verification code must be 6 digits'));
    }

    try {
      await _repository.verifyEmail(code);
      return right(null);
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }
}
