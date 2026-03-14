import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginUsernameChanged extends LoginEvent {
  final String username;

  const LoginUsernameChanged(this.username);

  @override
  List<Object?> get props => [username];
}

class LoginPasswordChanged extends LoginEvent {
  final String password;

  const LoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

class LoginWithGoogle extends LoginEvent {
  const LoginWithGoogle();
}

class LoginWithDiscord extends LoginEvent {
  const LoginWithDiscord();
}

class LoginWithDiscordCode extends LoginEvent {
  final String code;

  const LoginWithDiscordCode(this.code);

  @override
  List<Object?> get props => [code];
}

class LoginReset extends LoginEvent {
  const LoginReset();
}

class VerifyEmailSubmitted extends LoginEvent {
  final String code;

  const VerifyEmailSubmitted(this.code);

  @override
  List<Object?> get props => [code];
}

class CheckRoleStatus extends LoginEvent {
  const CheckRoleStatus();
}

class SelectRoleSubmitted extends LoginEvent {
  final String role;

  const SelectRoleSubmitted(this.role);

  @override
  List<Object?> get props => [role];
}
