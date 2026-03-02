import 'package:passion_tree_frontend/core/error/exceptions.dart';

/// Response from POST /auth/login
/// Backend sends OTP email and returns { success: true, message: "verification_required: ..." }
/// No tokens are returned at this stage.
class LoginOtpResponse {
  final bool success;
  final String message;

  LoginOtpResponse({
    required this.success,
    required this.message,
  });

  factory LoginOtpResponse.fromJson(Map<String, dynamic> json) {
    try {
      return LoginOtpResponse(
        success: json['success'] as bool,
        message: json['message'] as String? ?? '',
      );
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse LoginOtpResponse',
        originalError: e,
      );
    }
  }
}
