import 'package:passion_tree_frontend/features/authentication/domain/entities/user_profile.dart';

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
  Future<String> login({
    required String identifier,
    required String password,
  });

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

  /// Changes password
  Future<void> changePassword(String oldPassword, String newPassword);

  /// Deletes account
  Future<void> deleteUser();

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

}
