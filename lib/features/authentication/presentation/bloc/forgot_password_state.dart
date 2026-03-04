import 'package:equatable/equatable.dart';

enum ForgotPasswordStatus { initial, loading, success, failure }

class ForgotPasswordState extends Equatable {
  final String email;
  final String? emailError;
  final ForgotPasswordStatus status;
  final String? errorMessage;

  const ForgotPasswordState({
    this.email = '',
    this.emailError,
    this.status = ForgotPasswordStatus.initial,
    this.errorMessage,
  });

  ForgotPasswordState copyWith({
    String? email,
    String? emailError,
    ForgotPasswordStatus? status,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      emailError: emailError,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, emailError, status];
}
