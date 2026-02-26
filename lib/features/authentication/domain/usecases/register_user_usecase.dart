import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/error/failure_mapper.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class RegisterUserUseCase {
  final IAuthRepository _repository;

  RegisterUserUseCase(this._repository);

  Future<Either<Failure, String>> execute({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? bio,
    String? location,
    String? avatarUrl,
  }) async {
    // Validation logic
    if (username.trim().isEmpty) {
      return left(const ValidationFailure(message: 'Username cannot be empty'));
    }

    if (email.trim().isEmpty) {
      return left(const ValidationFailure(message: 'Email cannot be empty'));
    }

    if (!_isValidEmail(email)) {
      return left(const ValidationFailure(message: 'Invalid email format'));
    }

    if (password.isEmpty) {
      return left(const ValidationFailure(message: 'Password cannot be empty'));
    }

    if (password.length < 8) {
      return left(const ValidationFailure(message: 'Password must be at least 8 characters'));
    }

    if (firstName.trim().isEmpty) {
      return left(const ValidationFailure(message: 'First name cannot be empty'));
    }

    if (lastName.trim().isEmpty) {
      return left(const ValidationFailure(message: 'Last name cannot be empty'));
    }

    if (role.trim().isEmpty) {
      return left(const ValidationFailure(message: 'Role must be specified'));
    }

    if (role != 'student' && role != 'teacher' && role != 'pending') {
      return left(const ValidationFailure(message: 'Invalid role. Must be student, teacher, or pending'));
    }

    // Call repository and handle exceptions
    try {
      final userId = await _repository.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        bio: bio,
        location: location,
        avatarUrl: avatarUrl,
      );
      return right(userId);
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
