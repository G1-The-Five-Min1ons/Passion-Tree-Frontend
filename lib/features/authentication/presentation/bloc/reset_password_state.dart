import 'package:equatable/equatable.dart';

enum ResetPasswordStatus { initial, loading, success, failure }

class ResetPasswordState extends Equatable {
  final String code;
  final String password;
  final String confirmPassword;
  final String? codeError;
  final String? passwordError;
  final String? confirmPasswordError;
  final ResetPasswordStatus status;
  final String? errorMessage;

  const ResetPasswordState({
    this.code = '',
    this.password = '',
    this.confirmPassword = '',
    this.codeError,
    this.passwordError,
    this.confirmPasswordError,
    this.status = ResetPasswordStatus.initial,
    this.errorMessage,
  });

  ResetPasswordState copyWith({
    String? code,
    String? password,
    String? confirmPassword,
    String? codeError,
    String? passwordError,
    String? confirmPasswordError,
    ResetPasswordStatus? status,
    String? errorMessage,
  }) {
    return ResetPasswordState(
      code: code ?? this.code,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      codeError: codeError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        code,
        password,
        confirmPassword,
        codeError,
        passwordError,
        confirmPasswordError,
        status,
      ];
}
