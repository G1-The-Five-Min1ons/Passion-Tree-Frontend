import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class MarkRoleSelectedUseCase {
  final IAuthRepository repository;

  MarkRoleSelectedUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    try {
      await repository.markRoleSelected();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
