import 'package:equatable/equatable.dart';

enum VerifyEmailStatus { initial, loading, success, failure, cancelled }

enum ResendVerificationStatus { initial, loading, success, failure }

class VerifyEmailState extends Equatable {
  final String otpCode;
  final String? otpError;
  final VerifyEmailStatus status;
  final String? errorMessage;
  final String resendEmail;
  final String? resendEmailError;
  final ResendVerificationStatus resendStatus;
  final String? resendMessage;

  const VerifyEmailState({
    this.otpCode = '',
    this.otpError,
    this.status = VerifyEmailStatus.initial,
    this.errorMessage,
    this.resendEmail = '',
    this.resendEmailError,
    this.resendStatus = ResendVerificationStatus.initial,
    this.resendMessage,
  });

  VerifyEmailState copyWith({
    String? otpCode,
    String? otpError,
    VerifyEmailStatus? status,
    String? errorMessage,
    String? resendEmail,
    String? resendEmailError,
    ResendVerificationStatus? resendStatus,
    String? resendMessage,
  }) {
    return VerifyEmailState(
      otpCode: otpCode ?? this.otpCode,
      otpError: otpError,
      status: status ?? this.status,
      errorMessage: errorMessage,
      resendEmail: resendEmail ?? this.resendEmail,
      resendEmailError: resendEmailError,
      resendStatus: resendStatus ?? this.resendStatus,
      resendMessage: resendMessage,
    );
  }

  @override
  List<Object?> get props => [otpCode, otpError, status, errorMessage, resendEmail, resendEmailError, resendStatus, resendMessage,
  ];
}
