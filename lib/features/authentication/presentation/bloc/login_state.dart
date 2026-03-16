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
  accountReactivation,
}

class LoginState extends Equatable {
  final String username;
  final String password;
  final LoginStatus status;
  final String? errorMessage;
  final LoginNextStep? nextStep;
  final String otpResendEmail;
  final bool requiresReactivation;
  final int gracePeriodDays;

  const LoginState({
    this.username = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.nextStep,
    this.otpResendEmail = '',
    this.requiresReactivation = false,
    this.gracePeriodDays = 14,
  });

  LoginState copyWith({
    String? username,
    String? password,
    LoginStatus? status,
    String? errorMessage,
    LoginNextStep? nextStep,
    String? otpResendEmail,
    bool? requiresReactivation,
    int? gracePeriodDays,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      nextStep: nextStep ?? this.nextStep,
      otpResendEmail: otpResendEmail ?? this.otpResendEmail,
      requiresReactivation: requiresReactivation ?? this.requiresReactivation,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
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
        requiresReactivation,
        gracePeriodDays,
      ];
}
