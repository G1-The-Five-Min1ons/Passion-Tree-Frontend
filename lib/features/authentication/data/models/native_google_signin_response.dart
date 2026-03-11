import 'package:passion_tree_frontend/core/error/exceptions.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';

/// Response from POST /auth/native/google
class NativeGoogleSignInResponse {
  final bool success;
  final String token;
  final String userId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  NativeGoogleSignInResponse({
    required this.success,
    required this.token,
    required this.userId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory NativeGoogleSignInResponse.fromJson(Map<String, dynamic> json) {
    try {
      LogHandler.info('DEBUG: NativeGoogleSignInResponse.fromJson received: $json');
      LogHandler.info('DEBUG: json[\'data\'] = ${json['data']}');
      LogHandler.info('DEBUG: json[\'data\'] type = ${json['data'].runtimeType}');
      
      final user = json['data'] as Map<String, dynamic>;
      LogHandler.info('DEBUG: user map = $user');
      
      return NativeGoogleSignInResponse(
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
      LogHandler.error('DEBUG: Parse error: $e');
      LogHandler.error('DEBUG: Error type: ${e.runtimeType}');
      throw ParseException(
        message: 'Failed to parse NativeGoogleSignInResponse',
        originalError: e,
      );
    }
  }
}
