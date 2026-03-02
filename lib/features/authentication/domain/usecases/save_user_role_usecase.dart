import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class SaveUserRoleUseCase {
  final IAuthRepository repository;

  SaveUserRoleUseCase(this.repository);

  Future<Either<Failure, void>> call(String role) async {
    if (role != 'student' && role != 'teacher') {
      return Left(ValidationFailure(message: 'Invalid role. Must be "student" or "teacher"'));
    }

    try {
      await repository.saveUserRole(role);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
