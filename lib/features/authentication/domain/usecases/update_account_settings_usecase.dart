import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/error/failure_mapper.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class UpdateAccountSettingsUseCase {
  final IAuthRepository _repository;

  UpdateAccountSettingsUseCase(this._repository);

  Future<Either<Failure, void>> execute({
    required String firstName,
    required String lastName,
    String? location,
    String? bio,
    String? avatarUrl,
    String? phoneNumber,
  }) async {
    final validation = _validateInput(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );

    // If validation failed, return the failure early
    if (validation.isLeft()) return validation;

    // Call repository and handle exceptions
    try {
      await _repository.updateAccountSettings(
        firstName: firstName,
        lastName: lastName,
        location: location,
        bio: bio,
        avatarUrl: avatarUrl,
        phoneNumber: phoneNumber,
      );
      return right(null);
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    // Basic phone number validation (9-15 digits, can start with +)
    return RegExp(r'^[0-9+]{9,15}$').hasMatch(phoneNumber);
  }

  Either<Failure, void> _validateInput({
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) {
    if (firstName.trim().isEmpty) {
      return left(const ValidationFailure(message: 'First name cannot be empty'));
    }

    if (lastName.trim().isEmpty) {
      return left(const ValidationFailure(message: 'Last name cannot be empty'));
    }

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      if (!_isValidPhoneNumber(phoneNumber)) {
        return left(const ValidationFailure(message: 'Phone number format is invalid'));
      }
    }

    return right(null);
  }
}
