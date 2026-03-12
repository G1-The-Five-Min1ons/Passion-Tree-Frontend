import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String? bio;
  final String? location;
  final String? avatarUrl;

  const RegisterSubmitted({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.bio,
    this.location,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
    username,
    email,
    password,
    firstName,
    lastName,
    role,
    bio,
    location,
    avatarUrl,
  ];
}

class RegisterReset extends RegisterEvent {
  const RegisterReset();
}

// Multi-step flow events
class AutoLoginAfterRegister extends RegisterEvent {
  final String username;
  final String password;

  const AutoLoginAfterRegister({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class VerifyEmailAfterRegister extends RegisterEvent {
  final String otpCode;

  const VerifyEmailAfterRegister(this.otpCode);

  @override
  List<Object?> get props => [otpCode];
}

class SyncRoleAfterRegister extends RegisterEvent {
  const SyncRoleAfterRegister();
}

class CompleteRegistrationFlow extends RegisterEvent {
  const CompleteRegistrationFlow();
}

class RegisterWithGoogle extends RegisterEvent {
  const RegisterWithGoogle();
}

class RegisterWithDiscord extends RegisterEvent {
  const RegisterWithDiscord();
}
