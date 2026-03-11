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
  final bool rememberMe;
  final LoginStatus status;
  final String? errorMessage;
  final LoginNextStep? nextStep;
  final bool requiresReactivation;
  final int gracePeriodDays;

  const LoginState({
    this.username = '',
    this.password = '',
    this.rememberMe = false,
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.nextStep,
    this.requiresReactivation = false,
    this.gracePeriodDays = 14,
  });

  LoginState copyWith({
    String? username,
    String? password,
    bool? rememberMe,
    LoginStatus? status,
    String? errorMessage,
    LoginNextStep? nextStep,
    bool? requiresReactivation,
    int? gracePeriodDays,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      nextStep: nextStep ?? this.nextStep,
      requiresReactivation: requiresReactivation ?? this.requiresReactivation,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
    );
  }

  @override
  List<Object?> get props => [
        username,
        password,
        rememberMe,
        status,
        nextStep,
        requiresReactivation,
        gracePeriodDays,
      ];
}
