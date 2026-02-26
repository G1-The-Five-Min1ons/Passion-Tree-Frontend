import 'package:equatable/equatable.dart';

enum RegisterNextStep {
  otpVerification,
  roleSelection,
  complete,
}

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

/// State when registration is in progress
class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

/// State when registration is successful
class RegisterSuccess extends RegisterState {
  final String userId;
  final String? token;
  final String message;
  final RegisterNextStep nextStep;

  const RegisterSuccess({
    required this.userId,
    this.token,
    this.message = 'Registration successful',
    this.nextStep = RegisterNextStep.complete,
  });

  @override
  List<Object?> get props => [userId, token, message, nextStep];
}

/// State when registration fails
class RegisterFailure extends RegisterState {
  final String error;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  const RegisterFailure({
    required this.error,
    this.statusCode,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [
        statusCode,
        fieldErrors,
      ];
}
