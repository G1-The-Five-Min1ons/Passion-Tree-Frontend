import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final IAuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) async {
    try {
      await repository.forgotPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
