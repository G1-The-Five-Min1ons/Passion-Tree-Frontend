import 'package:equatable/equatable.dart';

abstract class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();

  @override
  List<Object?> get props => [];
}

class CodeChanged extends ResetPasswordEvent {
  final String code;

  const CodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

class PasswordChanged extends ResetPasswordEvent {
  final String password;

  const PasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class ConfirmPasswordChanged extends ResetPasswordEvent {
  final String confirmPassword;

  const ConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class SubmitResetPassword extends ResetPasswordEvent {
  const SubmitResetPassword();
}
