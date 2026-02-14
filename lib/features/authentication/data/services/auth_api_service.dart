import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/auth_models.dart';

class AuthApiService {
  final http.Client _client;

  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.authRegister),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return RegisterResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw AuthException(
          message: errorData['error'] ?? errorData['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Network error: Unable to connect to server',
        statusCode: 0,
      );
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.authLogin),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw AuthException(
          message: errorData['error'] ?? errorData['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Network error: Unable to connect to server',
        statusCode: 0,
      );
    }
  }

  /// Verify email with code
  Future<void> verifyEmail(String code) async {
    try {
      final request = VerifyEmailRequest(code: code);
      final response = await _client.post(
        Uri.parse(ApiConfig.authVerifyEmail),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw AuthException(
          message: errorData['error'] ?? errorData['message'] ?? 'Email verification failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Network error: Unable to connect to server',
        statusCode: 0,
      );
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail(String email) async {
    try {
      final request = ResendVerificationRequest(email: email);
      final response = await _client.post(
        Uri.parse(ApiConfig.authResendVerification),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw AuthException(
          message: errorData['error'] ?? errorData['message'] ?? 'Failed to resend verification email',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Network error: Unable to connect to server',
        statusCode: 0,
      );
    }
  }

  /// Request password reset
  Future<void> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _client.post(
        Uri.parse(ApiConfig.authForgotPassword),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw AuthException(
          message: errorData['error'] ?? errorData['message'] ?? 'Failed to process password reset request',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Network error: Unable to connect to server',
        statusCode: 0,
      );
    }
  }

  /// Reset password with code
  Future<void> resetPassword(String code, String newPassword) async {
    try {
      final request = ResetPasswordRequest(
        code: code,
        newPassword: newPassword,
      );
      final response = await _client.post(
        Uri.parse(ApiConfig.authResetPassword),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw AuthException(
          message: errorData['error'] ?? errorData['message'] ?? 'Password reset failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Network error: Unable to connect to server',
        statusCode: 0,
      );
    }
  }

  /// Get user profile (requires authentication)
  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.authGetProfile),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw AuthException(
          message: errorData['error'] ?? errorData['message'] ?? 'Failed to fetch profile',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Network error: Unable to connect to server',
        statusCode: 0,
      );
    }
  }

  /// Change password (requires authentication)
  Future<void> changePassword(
    String token,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final request = ChangePasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      final response = await _client.put(
        Uri.parse(ApiConfig.authChangePassword),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw AuthException(
          message: errorData['error'] ?? errorData['message'] ?? 'Password change failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Network error: Unable to connect to server',
        statusCode: 0,
      );
    }
  }

  /// Delete user account (requires authentication)
  Future<void> deleteUser(String token) async {
    try {
      final response = await _client.delete(
        Uri.parse(ApiConfig.authDeleteUser),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw AuthException(
          message: errorData['error'] ?? errorData['message'] ?? 'Failed to delete account',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Network error: Unable to connect to server',
        statusCode: 0,
      );
    }
  }
  void dispose() {
    _client.close();
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  final int statusCode;

  AuthException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => message;
}
