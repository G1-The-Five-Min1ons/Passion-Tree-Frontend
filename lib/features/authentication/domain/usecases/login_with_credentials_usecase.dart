import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/error/failure_mapper.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class LoginWithCredentialsUseCase {
  final IAuthRepository _repository;

  LoginWithCredentialsUseCase(this._repository);

  Future<Either<Failure, String>> execute({
    required String identifier,
    required String password,
    bool confirmReactivate = false,
  }) async {
    // Validation
    if (identifier.trim().isEmpty) {
      return left(const ValidationFailure(message: 'Username or email cannot be empty'));
    }
    
    if (password.isEmpty) {
      return left(const ValidationFailure(message: 'Password cannot be empty'));
    }

    // Call repository and handle exceptions
    try {
      final token = await _repository.login(
        identifier: identifier,
        password: password,
        confirmReactivate: confirmReactivate,
      );
      return right(token);
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }
}
