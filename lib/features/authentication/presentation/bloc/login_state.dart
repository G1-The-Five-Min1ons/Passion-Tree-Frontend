import 'package:equatable/equatable.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  failure,
}

enum LoginNextStep {
  otpVerification,
  checkingRole,
  roleSelection,
  complete,
}

class LoginState extends Equatable {
  final String username;
  final String password;
  final LoginStatus status;
  final String? errorMessage;
  final LoginNextStep? nextStep;
  final String otpResendEmail;

  const LoginState({
    this.username = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.nextStep,
    this.otpResendEmail = '',
  });

  LoginState copyWith({
    String? username,
    String? password,
    LoginStatus? status,
    String? errorMessage,
    LoginNextStep? nextStep,
    String? otpResendEmail,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      nextStep: nextStep ?? this.nextStep,
      otpResendEmail: otpResendEmail ?? this.otpResendEmail,
    );
  }

  @override
  List<Object?> get props => [
        username,
        password,
        status,
        errorMessage,
        nextStep,
        otpResendEmail,
      ];
}
