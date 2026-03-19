import 'package:equatable/equatable.dart';

abstract class VerifyEmailEvent extends Equatable {
  const VerifyEmailEvent();

  @override
  List<Object?> get props => [];
}

class OtpCodeChanged extends VerifyEmailEvent {
  final String code;

  const OtpCodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

class ResendEmailChanged extends VerifyEmailEvent {
  final String email;

  const ResendEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class SubmitVerifyEmail extends VerifyEmailEvent {
  const SubmitVerifyEmail();
}

class ResendVerificationEmailRequested extends VerifyEmailEvent {
  const ResendVerificationEmailRequested();
}

class CancelVerifyEmail extends VerifyEmailEvent {
  const CancelVerifyEmail();
}
