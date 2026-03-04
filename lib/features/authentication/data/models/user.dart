import 'package:passion_tree_frontend/core/error/exceptions.dart';

class User {
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

  User({
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

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        userId: json['user_id'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        role: json['role'] as String,
        heartCount: json['heart_count'] as int,
        isEmailVerified: json['is_email_verified'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse User',
        originalError: e,
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'username': username,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'role': role,
    'heart_count': heartCount,
    'is_email_verified': isEmailVerified,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
