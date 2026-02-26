import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/error/failure_mapper.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class LoginWithGoogleUseCase {
  final IAuthRepository _repository;

  LoginWithGoogleUseCase(this._repository);

  Future<Either<Failure, bool>> execute() async {
    try {
      final account = await GoogleSignIn.instance.authenticate();
      
      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        return left(const AuthFailure(message: 'Failed to retrieve Google ID Token'));
      }

      await _repository.nativeGoogleSignIn(idToken);
      
      return right(true);
    } catch (e) {
      if (e.toString().toLowerCase().contains('cancel')) {
        return left(const AuthFailure(message: 'Google sign-in was cancelled'));
      }
      return left(FailureMapper.fromException(e));
    }
  }
}
