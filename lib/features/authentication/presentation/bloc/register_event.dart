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
  final String? bio;
  final String? location;
  final String? avatarUrl;

  const RegisterSubmitted({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
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
    bio,
    location,
    avatarUrl,
  ];
}

class RegisterReset extends RegisterEvent {
  const RegisterReset();
}
