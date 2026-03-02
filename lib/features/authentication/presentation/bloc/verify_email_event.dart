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

class SubmitVerifyEmail extends VerifyEmailEvent {
  const SubmitVerifyEmail();
}

class CancelVerifyEmail extends VerifyEmailEvent {
  const CancelVerifyEmail();
}
