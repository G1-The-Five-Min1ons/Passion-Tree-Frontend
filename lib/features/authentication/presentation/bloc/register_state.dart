import 'package:equatable/equatable.dart';

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

  const RegisterSuccess({
    required this.userId,
    this.token,
    this.message = 'Registration successful',
  });

  @override
  List<Object?> get props => [userId, token, message];
}

/// State when registration fails
class RegisterFailure extends RegisterState {
  final String error;
  final int? statusCode;

  const RegisterFailure({
    required this.error,
    this.statusCode,
  });

  @override
  List<Object?> get props => [error, statusCode];
}
