import 'package:passion_tree_frontend/core/error/exceptions.dart';

/// Response from POST /auth/login
/// Backend sends OTP email and returns { success: true, message: "verification_required: ..." }
/// OR if account is deactivated: { success: true, requires_reactivation: true, grace_period_days: 14 }
/// No tokens are returned at this stage.
class LoginOtpResponse {
  final bool success;
  final String message;
  final bool requiresReactivation;
  final int gracePeriodDays;

  LoginOtpResponse({
    required this.success,
    required this.message,
    this.requiresReactivation = false,
    this.gracePeriodDays = 14,
  });

  factory LoginOtpResponse.fromJson(Map<String, dynamic> json) {
    try {
      final requiresReactivation = json['requires_reactivation'] as bool? ?? false;
      
      if (requiresReactivation) {
        throw AccountReactivationRequiredException(
          message: 'Your account is temporarily deactivated.',
          gracePeriodDays: json['grace_period_days'] as int? ?? 14,
        );
      }
      
      return LoginOtpResponse(
        success: json['success'] as bool,
        message: json['message'] as String? ?? '',
        requiresReactivation: false,
      );
    } catch (e) {
      if (e is AccountReactivationRequiredException) rethrow;
      throw ParseException(
        message: 'Failed to parse LoginOtpResponse',
        originalError: e,
      );
    }
  }
}
