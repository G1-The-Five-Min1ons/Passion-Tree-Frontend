import 'package:passion_tree_frontend/core/error/exceptions.dart';

class RegisterResponse {
  final bool success;
  final String message;
  final String userId;
  final String? token;

  RegisterResponse({
    required this.success,
    required this.message,
    required this.userId,
    this.token,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>?;
      return RegisterResponse(
        success: json['success'] as bool,
        message: json['message'] as String,
        userId: data?['user_id'] as String,
        token: data?['token'] as String?,
      );
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse RegisterResponse',
        originalError: e,
      );
    }
  }
}
