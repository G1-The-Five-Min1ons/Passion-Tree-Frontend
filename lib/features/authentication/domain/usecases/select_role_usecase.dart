import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/error/failure_mapper.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class SelectRoleUseCase {
  final IAuthRepository _repository;

  SelectRoleUseCase(this._repository);

  Future<Either<Failure, void>> execute(String role) async {
    if (role.trim().isEmpty) {
      return left(const ValidationFailure(message: 'Role cannot be empty'));
    }

    if (role != 'student' && role != 'teacher') {
      return left(const ValidationFailure(message: 'Invalid role. Must be student or teacher'));
    }

    try {
      await _repository.selectRole(role);
      return right(null);
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }
}
