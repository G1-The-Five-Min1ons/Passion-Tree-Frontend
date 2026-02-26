import 'dart:convert';
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/core/error/exceptions.dart';
import 'package:passion_tree_frontend/core/network/api_handler.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/register_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/register_response.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/login_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/login_otp_response.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/verify_email_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/verify_email_response.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/resend_verification_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/forgot_password_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/reset_password_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/change_password_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/native_google_signin_response.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/native_discord_signin_response.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/select_role_request.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponse> register(RegisterRequest request);
  Future<LoginOtpResponse> login(LoginRequest request);
  Future<VerifyEmailResponse> verifyEmail(VerifyEmailRequest request);
  Future<void> resendVerificationEmail(ResendVerificationRequest request);
  Future<void> forgotPassword(ForgotPasswordRequest request);
  Future<void> resetPassword(ResetPasswordRequest request);
  Future<Map<String, dynamic>> getProfile(String token);
  Future<void> changePassword(String token, ChangePasswordRequest request);
  Future<void> deleteUser(String token);
  Future<NativeGoogleSignInResponse> nativeGoogleSignIn(String idToken);
  Future<NativeDiscordSignInResponse> nativeDiscordSignIn(String code);
  Future<VerifyEmailResponse> refreshToken(String refreshTokenValue);
  Future<void> selectRole(String token, SelectRoleRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiHandler _apiHandler;

  AuthRemoteDataSourceImpl({ApiHandler? apiHandler})
      : _apiHandler = apiHandler ?? ApiHandler();

  @override
  Future<RegisterResponse> register(RegisterRequest request) async {
    LogHandler.separator(title: 'AUTH REMOTE · REGISTER');
    final response = await _apiHandler.post(
      url: ApiConfig.authRegister,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess && response.statusCode == 201) {
      LogHandler.success('Registration successful');
      final raw = <String, dynamic>{
        'success': response.success,
        'message': response.message,
        'data': response.data,
      };
      return RegisterResponse.fromJson(raw);
    }
    throw _handleError(response, 'register');
  }

  @override
  Future<LoginOtpResponse> login(LoginRequest request) async {
    LogHandler.separator(title: 'AUTH REMOTE · LOGIN');
    final response = await _apiHandler.post(
      url: ApiConfig.authLogin,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('OTP sent to email');
      return LoginOtpResponse(
        success: response.success,
        message: response.message ?? '',
      );
    }
    throw _handleError(response, 'login');
  }

  @override
  Future<VerifyEmailResponse> verifyEmail(VerifyEmailRequest request) async {
    LogHandler.separator(title: 'AUTH REMOTE · VERIFY EMAIL');
    final response = await _apiHandler.post(
      url: ApiConfig.authVerifyEmail,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      final data = response.data as Map<String, dynamic>;
      LogHandler.success('Email verified — tokens received');
      return VerifyEmailResponse(
        success: true,
        message: response.message ?? '',
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
    }
    throw _handleError(response, 'verifyEmail');
  }

  @override
  Future<void> resendVerificationEmail(ResendVerificationRequest request) async {
    LogHandler.separator(title: 'AUTH REMOTE · RESEND VERIFICATION');
    final response = await _apiHandler.post(
      url: ApiConfig.authResendVerification,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Verification email resent');
      return;
    }
    throw _handleError(response, 'resendVerification');
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    LogHandler.separator(title: 'AUTH REMOTE · FORGOT PASSWORD');
    final response = await _apiHandler.post(
      url: ApiConfig.authForgotPassword,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Password reset email sent');
      return;
    }
    throw _handleError(response, 'forgotPassword');
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    LogHandler.separator(title: 'AUTH REMOTE · RESET PASSWORD');
    final response = await _apiHandler.post(
      url: ApiConfig.authResetPassword,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Password reset successful');
      return;
    }
    throw _handleError(response, 'resetPassword');
  }

  @override
  Future<Map<String, dynamic>> getProfile(String token) async {
    LogHandler.separator(title: 'AUTH REMOTE · GET PROFILE');
    final response = await _apiHandler.get(
      url: ApiConfig.authGetProfile,
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Profile fetched');
      return <String, dynamic>{
        'success': response.success,
        'message': response.message,
        'data': response.data,
      };
    }
    throw _handleError(response, 'getProfile');
  }

  @override
  Future<void> changePassword(String token, ChangePasswordRequest request) async {
    LogHandler.separator(title: 'AUTH REMOTE · CHANGE PASSWORD');
    final response = await _apiHandler.put(
      url: ApiConfig.authChangePassword,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Password changed');
      return;
    }
    throw _handleError(response, 'changePassword');
  }

  @override
  Future<void> deleteUser(String token) async {
    LogHandler.separator(title: 'AUTH REMOTE · DELETE USER');
    final response = await _apiHandler.delete(
      url: ApiConfig.authDeleteUser,
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Account deleted');
      return;
    }
    throw _handleError(response, 'deleteUser');
  }

  @override
  Future<NativeGoogleSignInResponse> nativeGoogleSignIn(String idToken) async {
    LogHandler.separator(title: 'AUTH REMOTE · NATIVE GOOGLE SIGN-IN');
    final response = await _apiHandler.post(
      url: ApiConfig.authNativeGoogleSignIn,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({'id_token': idToken}),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Google sign-in successful');
      final raw = <String, dynamic>{
        'success': response.success,
        'token': (response.data as Map<String, dynamic>?)?['token'] ?? '',
        'user': (response.data as Map<String, dynamic>?)?['user'],
      };
      return NativeGoogleSignInResponse.fromJson(raw);
    }
    throw _handleError(response, 'nativeGoogleSignIn');
  }

  @override
  Future<NativeDiscordSignInResponse> nativeDiscordSignIn(String code) async {
    LogHandler.separator(title: 'AUTH REMOTE · NATIVE DISCORD SIGN-IN');
    final response = await _apiHandler.post(
      url: ApiConfig.authNativeDiscordSignIn,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({'code': code}),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Discord sign-in successful');
      final raw = <String, dynamic>{
        'success': response.success,
        'token': (response.data as Map<String, dynamic>?)?['token'] ?? '',
        'user': (response.data as Map<String, dynamic>?)?['user'],
      };
      return NativeDiscordSignInResponse.fromJson(raw);
    }
    throw _handleError(response, 'nativeDiscordSignIn');
  }

  @override
  Future<VerifyEmailResponse> refreshToken(String refreshTokenValue) async {
    LogHandler.separator(title: 'AUTH REMOTE · REFRESH TOKEN');
    final response = await _apiHandler.post(
      url: ApiConfig.authRefreshToken,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({'refresh_token': refreshTokenValue}),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      final data = response.data as Map<String, dynamic>;
      LogHandler.success('Token refreshed');
      return VerifyEmailResponse(
        success: true,
        message: response.message ?? '',
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
    }
    throw _handleError(response, 'refreshToken');
  }

  AuthException _handleError(ApiResponse response, String context) {
    final msg = _getUserFriendlyMessage(
      response.error ?? response.message ?? '',
      context,
    );
    LogHandler.error('$context failed: $msg');
    return AuthException(message: msg, statusCode: response.statusCode);
  }

  @override
  Future<void> selectRole(String token, SelectRoleRequest request) async {
    LogHandler.separator(title: 'AUTH REMOTE · SELECT ROLE');
    final response = await _apiHandler.put(
      url: ApiConfig.authUpdateUser,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Role selected: ${request.role}');
      return;
    }
    throw _handleError(response, 'selectRole');
  }

  String _getUserFriendlyMessage(String backendError, String context) {
    final errorLower = backendError.toLowerCase();
    if (context == 'login') {
      if (errorLower.contains('invalid') ||
          errorLower.contains('password') ||
          errorLower.contains('incorrect') ||
          errorLower.contains('username') ||
          errorLower.contains('email')) {
        return 'Invalid username/email or password';
      }
      if (errorLower.contains('locked')) {
        return backendError;
      }
      return 'Login failed';
    }
    return backendError.isNotEmpty ? backendError : 'Something went wrong';
  }
}
