import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/error/failure_mapper.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/user_profile.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class GetProfileUseCase {
  final IAuthRepository _repository;

  GetProfileUseCase(this._repository);

  Future<Either<Failure, UserProfile>> execute() async {
    try {
      final profile = await _repository.getProfile();
      return right(profile);
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }
}
