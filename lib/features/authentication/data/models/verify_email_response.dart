import 'package:passion_tree_frontend/core/error/exceptions.dart';

/// Response from POST /auth/verify-email
/// Returns access_token + refresh_token after OTP verification.
class VerifyEmailResponse {
  final bool success;
  final String message;
  final String accessToken;
  final String refreshToken;

  VerifyEmailResponse({
    required this.success,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
  });

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;
      return VerifyEmailResponse(
        success: json['success'] as bool,
        message: json['message'] as String? ?? '',
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse VerifyEmailResponse',
        originalError: e,
      );
    }
  }
}
