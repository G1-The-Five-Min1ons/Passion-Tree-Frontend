import 'package:passion_tree_frontend/features/authentication/domain/entities/user_profile.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/teacher_verification_status.dart';

abstract class IAuthRepository {
  /// Registers a new user. Returns user ID.
  Future<String> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? bio,
    String? location,
    String? avatarUrl,
  });

  /// Logs in and triggers OTP email. Returns success message.
  Future<String> login({required String identifier, required String password});

  /// Verifies email OTP and saves tokens. Returns formatted message or user data if available.
  Future<void> verifyEmail(String code);

  /// Resends verification email
  Future<void> resendVerificationEmail(String email);

  /// Requests password reset email
  Future<void> forgotPassword(String email);

  /// Resets password with code
  Future<void> resetPassword(String code, String newPassword);

  /// Returns [UserProfile] entity with user and optional profile data
  Future<UserProfile> getProfile();

  /// Updates account settings in both user and profile tables
  Future<void> updateAccountSettings({
    required String username,
    required String firstName,
    required String lastName,
    String? location,
    String? bio,
    String? avatarUrl,
    String? phoneNumber,
  });

  /// Changes password
  Future<void> changePassword(String oldPassword, String newPassword);

  /// Deletes account
  Future<void> deleteUser(String password);

  /// Deactivates account temporarily and revokes active sessions
  Future<void> deactivateAccount();

  /// Logs out locally and optionally remotely
  Future<void> logout();

  /// Validates if a role is selected (local check)
  Future<bool> hasSelectedRole();

  /// Marks role as selected
  Future<void> markRoleSelected();

  /// Saves the user role locally
  Future<void> saveUserRole(String role);

  /// Selects a role for the user via API and saves locally
  Future<void> selectRole(String role);

  /// Checks if user is logged in
  Future<bool> isLoggedIn();

  /// Gets the current user ID
  Future<String?> getUserId();

  /// Gets the current username
  Future<String?> getUsername();

  /// Gets the current user role
  Future<String?> getUserRole();

  /// Gets the current heart count
  Future<int> getHeartCount();

  /// Clears authentication data (logout)
  Future<void> clearAuth();

  /// Performs Google Sign-In and returns [UserProfile]
  /// [idToken] is received from Google SDK in Flutter
  Future<UserProfile> nativeGoogleSignIn(String idToken);

  /// Performs Discord Sign-In and returns [UserProfile]
  /// [code] is the authorization code from Discord OAuth2
  Future<UserProfile> nativeDiscordSignIn(String code);

  /// Performs Google Sign-In using google_sign_in package
  /// Handles the complete flow: Google SDK login -> Backend verification
  Future<void> signInWithGoogle();

  /// Performs Discord Sign-In using authorization code
  /// [code] is the authorization code from Discord OAuth2
  Future<void> signInWithDiscord(String code);

  /// Gets current teacher verification status for account gating.
  Future<TeacherVerificationStatus> getTeacherVerificationStatus();

  /// Submits teacher verification application with phone binding.
  Future<void> applyForTeacher({
    required String phoneNumber,
    required String reason,
    required String teachingHistory,
  });
}
