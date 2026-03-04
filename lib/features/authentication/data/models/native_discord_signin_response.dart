import 'package:passion_tree_frontend/core/error/exceptions.dart';

class NativeDiscordSignInResponse {
  final bool success;
  final String token;
  final String userId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  NativeDiscordSignInResponse({
    required this.success,
    required this.token,
    required this.userId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory NativeDiscordSignInResponse.fromJson(Map<String, dynamic> json) {
    try {
      final user = json['user'] as Map<String, dynamic>;
      return NativeDiscordSignInResponse(
        success: json['success'] as bool? ?? true,
        token: json['token'] as String,
        userId: user['user_id'] as String,
        username: user['username'] as String,
        email: user['email'] as String,
        firstName: user['first_name'] as String,
        lastName: user['last_name'] as String,
        role: user['role'] as String,
      );
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse NativeDiscordSignInResponse',
        originalError: e,
      );
    }
  }
}
