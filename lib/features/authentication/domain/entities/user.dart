import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String userId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final int heartCount;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.userId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.heartCount,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        username,
        email,
        firstName,
        lastName,
        role,
        heartCount,
        isEmailVerified,
        createdAt,
        updatedAt,
      ];
}
