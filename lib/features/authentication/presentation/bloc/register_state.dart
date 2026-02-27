import 'package:equatable/equatable.dart';

enum RegisterStatus { initial, loading, success, failure }

enum RegisterNextStep {
  none,
  autoLogin,
  otpVerification,
  roleSync,
  complete,
}

class RegisterState extends Equatable {
  final RegisterStatus status;
  final RegisterNextStep nextStep;
  final String? errorMessage;
  final Map<String, List<String>>? fieldErrors;
  final String? userId;
  final String? token;
  final String? successMessage;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.nextStep = RegisterNextStep.none,
    this.errorMessage,
    this.fieldErrors,
    this.userId,
    this.token,
    this.successMessage,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    RegisterNextStep? nextStep,
    String? errorMessage,
    Map<String, List<String>>? fieldErrors,
    String? userId,
    String? token,
    String? successMessage,
  }) {
    return RegisterState(
      status: status ?? this.status,
      nextStep: nextStep ?? this.nextStep,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        nextStep,
        fieldErrors,
        userId,
        token,
      ];
}
