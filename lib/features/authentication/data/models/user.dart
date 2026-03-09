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
      // Parse dates with proper error handling
      // Go backend uses 'create_at'/'update_at'
      final createdAtRaw = json['create_at'] ?? json['created_at'];
      final updatedAtRaw = json['update_at'] ?? json['updated_at'];

      DateTime? createdAt;
      DateTime? updatedAt;

      if (createdAtRaw != null) {
        try {
          createdAt = DateTime.parse(createdAtRaw as String);
        } catch (e) {
          throw ParseException(
            message: 'Invalid date format for created_at: $createdAtRaw',
            originalError: e,
          );
        }
      }

      if (updatedAtRaw != null) {
        try {
          updatedAt = DateTime.parse(updatedAtRaw as String);
        } catch (e) {
          throw ParseException(
            message: 'Invalid date format for updated_at: $updatedAtRaw',
            originalError: e,
          );
        }
      }

      return User(
        userId: json['user_id'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        role: json['role'] as String,
        heartCount: (json['heart_count'] as int?) ?? 0,
        isEmailVerified: json['is_email_verified'] as bool? ?? false,
        createdAt: createdAt ?? DateTime.now(),
        updatedAt: updatedAt ?? DateTime.now(),
      );
    } catch (e) {
      throw ParseException(message: 'Failed to parse User', originalError: e);
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
    'create_at': createdAt.toIso8601String(),
    'update_at': updatedAt.toIso8601String(),
  };

  User copyWith({
    String? userId,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    int? heartCount,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      heartCount: heartCount ?? this.heartCount,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
