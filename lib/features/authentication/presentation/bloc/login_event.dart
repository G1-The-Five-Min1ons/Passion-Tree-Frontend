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

class LoginRememberMeToggled extends LoginEvent {
  final bool rememberMe;

  const LoginRememberMeToggled(this.rememberMe);

  @override
  List<Object?> get props => [rememberMe];
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
