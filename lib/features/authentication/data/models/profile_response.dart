import 'package:passion_tree_frontend/core/error/exceptions.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/user.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/profile.dart';

class ProfileResponse {
  final bool success;
  final String message;
  final User user;
  final Profile? profile;

  ProfileResponse({
    required this.success,
    required this.message,
    required this.user,
    this.profile,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw ParseException(
          message: 'Missing or null "data" field in ProfileResponse',
        );
      }

      final userJson = data['user'] as Map<String, dynamic>?;
      if (userJson == null) {
        throw ParseException(
          message: 'Missing or null "user" field in ProfileResponse data',
        );
      }

      Profile? profile;
      final profileJson = data['profile'] as Map<String, dynamic>?;
      if (profileJson != null) {
        try {
          profile = Profile.fromJson(profileJson);
        } catch (e) {
          // Profile is optional, so we can continue without it
          profile = null;
        }
      }

      return ProfileResponse(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String? ?? '',
        user: User.fromJson(userJson),
        profile: profile,
      );
    } catch (e) {
      if (e is ParseException) rethrow;
      throw ParseException(
        message: 'Failed to parse ProfileResponse',
        originalError: e,
      );
    }
  }
}
