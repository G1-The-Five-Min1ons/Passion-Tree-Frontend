import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/error/failure_mapper.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class GetUserRoleUseCase {
  final IAuthRepository _repository;

  GetUserRoleUseCase(this._repository);

  Future<Either<Failure, String?>> execute() async {
    try {
      final role = await _repository.getUserRole();
      return right(role);
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }
}
