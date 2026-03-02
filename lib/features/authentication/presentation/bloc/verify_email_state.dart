import 'package:equatable/equatable.dart';

enum VerifyEmailStatus { initial, loading, success, failure, cancelled }

class VerifyEmailState extends Equatable {
  final String otpCode;
  final String? otpError;
  final VerifyEmailStatus status;
  final String? errorMessage;

  const VerifyEmailState({
    this.otpCode = '',
    this.otpError,
    this.status = VerifyEmailStatus.initial,
    this.errorMessage,
  });

  VerifyEmailState copyWith({
    String? otpCode,
    String? otpError,
    VerifyEmailStatus? status,
    String? errorMessage,
  }) {
    return VerifyEmailState(
      otpCode: otpCode ?? this.otpCode,
      otpError: otpError,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [otpCode, otpError, status];
}
