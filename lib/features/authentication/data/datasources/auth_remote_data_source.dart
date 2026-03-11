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
import 'package:passion_tree_frontend/features/authentication/data/models/update_user_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/update_profile_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/apply_teacher_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/teacher_verification_status_model.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponse> register(RegisterRequest request);
  Future<LoginOtpResponse> login(LoginRequest request, {bool confirmReactivate = false});
  Future<VerifyEmailResponse> verifyEmail(VerifyEmailRequest request);
  Future<void> resendVerificationEmail(ResendVerificationRequest request);
  Future<void> forgotPassword(ForgotPasswordRequest request);
  Future<void> resetPassword(ResetPasswordRequest request);
  Future<Map<String, dynamic>> getProfile(String token);
  Future<void> updateUser(String token, UpdateUserRequest request);
  Future<void> updateProfile(String token, UpdateProfileRequest request);
  Future<void> changePassword(String token, ChangePasswordRequest request);
  Future<void> deleteUser(String token, String password);
  Future<void> deactivateAccount(String token);
  Future<void> reactivateAccount(String token);
  Future<void> logout(String token);
  Future<NativeGoogleSignInResponse> nativeGoogleSignIn(String idToken);
  Future<NativeDiscordSignInResponse> nativeDiscordSignIn(String code);
  Future<VerifyEmailResponse> refreshToken(String refreshTokenValue);
  Future<void> selectRole(String token, SelectRoleRequest request);
  Future<TeacherVerificationStatusModel> getTeacherVerificationStatus(
    String token,
  );
  Future<void> applyForTeacher(String token, ApplyTeacherRequest request);
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
      try {
        LogHandler.success('Registration successful');
        final raw = <String, dynamic>{
          'success': response.success,
          'message': response.message,
          'data': response.data,
        };
        return RegisterResponse.fromJson(raw);
      } catch (e) {
        if (e is ParseException) rethrow;
        throw ParseException(
          message: 'Failed to parse register response: $e',
          originalError: e,
        );
      }
    }
    throw _handleError(response, 'register');
  }

  @override
  Future<LoginOtpResponse> login(LoginRequest request, {bool confirmReactivate = false}) async {
    LogHandler.separator(title: 'AUTH REMOTE · LOGIN');
    
    // Add query parameter if confirming reactivation
    String url = ApiConfig.authLogin;
    if (confirmReactivate) {
      url = '$url?confirm_reactivate=true';
    }
    
    final response = await _apiHandler.post(
      url: url,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('OTP sent to email' + (confirmReactivate ? ' (with reactivation)' : ''));
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
      try {
        final data = _parseMap(response.data, 'response.data');
        LogHandler.success('Email verified — tokens received');
        return VerifyEmailResponse(
          success: true,
          message: response.message ?? '',
          accessToken: _parseString(data['access_token'], 'access_token'),
          refreshToken: _parseString(data['refresh_token'], 'refresh_token'),
        );
      } catch (e) {
        if (e is ParseException) rethrow;
        throw ParseException(
          message: 'Failed to parse verifyEmail response: $e',
          originalError: e,
        );
      }
    }
    throw _handleError(response, 'verifyEmail');
  }

  @override
  Future<void> resendVerificationEmail(
    ResendVerificationRequest request,
  ) async {
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
  Future<void> updateUser(String token, UpdateUserRequest request) async {
    LogHandler.separator(title: 'AUTH REMOTE · UPDATE USER');
    final response = await _apiHandler.put(
      url: ApiConfig.authUpdateUser,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('User info updated');
      return;
    }
    throw _handleError(response, 'updateUser');
  }

  @override
  Future<void> updateProfile(String token, UpdateProfileRequest request) async {
    LogHandler.separator(title: 'AUTH REMOTE · UPDATE PROFILE');
    final response = await _apiHandler.put(
      url: ApiConfig.authUpdateProfile,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Profile info updated');
      return;
    }
    throw _handleError(response, 'updateProfile');
  }

  @override
  Future<void> changePassword(
    String token,
    ChangePasswordRequest request,
  ) async {
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
  Future<void> deleteUser(String token, String password) async {
    LogHandler.separator(title: 'AUTH REMOTE · DELETE USER');
    final response = await _apiHandler.delete(
      url: ApiConfig.authDeleteUser,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode({'password': password}),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Account deleted');
      return;
    }
    throw _handleError(response, 'deleteUser');
  }

  @override
  Future<void> deactivateAccount(String token) async {
    LogHandler.separator(title: 'AUTH REMOTE · DEACTIVATE ACCOUNT');
    final response = await _apiHandler.post(
      url: ApiConfig.authDeactivate,
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Account deactivated');
      return;
    }
    throw _handleError(response, 'deactivateAccount');
  }

  @override
  Future<void> reactivateAccount(String token) async {
    LogHandler.separator(title: 'AUTH REMOTE · REACTIVATE ACCOUNT');
    final response = await _apiHandler.post(
      url: ApiConfig.authReactivate,
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Account reactivated');
      return;
    }
    throw _handleError(response, 'reactivateAccount');
  }

  @override
  Future<void> logout(String token) async {
    LogHandler.separator(title: 'AUTH REMOTE · LOGOUT');
    final response = await _apiHandler.post(
      url: ApiConfig.authLogout,
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );
    if (response.isSuccess) {
      LogHandler.success('Logged out all sessions');
      return;
    }
    throw _handleError(response, 'logout');
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
      try {
        // Backend may return user payload under either `user` or `data` at root level.
        final fullBody = _parseMap(response.rawBody, 'rawBody');
        LogHandler.success('Google sign-in successful');
        final userPayload = fullBody['user'] ?? fullBody['data'];
        final raw = <String, dynamic>{
          'success': response.success,
          'token': _parseString(fullBody['token'], 'token'),
          'user': userPayload,
        };
        return NativeGoogleSignInResponse.fromJson(raw);
      } catch (e) {
        if (e is ParseException) rethrow;
        throw ParseException(
          message: 'Failed to parse nativeGoogleSignIn response: $e',
          originalError: e,
        );
      }
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
      try {
        // Backend may return user payload under either `user` or `data` at root level.
        final fullBody = _parseMap(response.rawBody, 'rawBody');
        LogHandler.success('Discord sign-in successful');
        final userPayload = fullBody['user'] ?? fullBody['data'];
        final raw = <String, dynamic>{
          'success': response.success,
          'token': _parseString(fullBody['token'], 'token'),
          'user': userPayload,
        };
        return NativeDiscordSignInResponse.fromJson(raw);
      } catch (e) {
        if (e is ParseException) rethrow;
        throw ParseException(
          message: 'Failed to parse nativeDiscordSignIn response: $e',
          originalError: e,
        );
      }
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
      try {
        final data = _parseMap(response.data, 'response.data');
        LogHandler.success('Token refreshed');
        return VerifyEmailResponse(
          success: true,
          message: response.message ?? '',
          accessToken: _parseString(data['access_token'], 'access_token'),
          refreshToken: _parseString(data['refresh_token'], 'refresh_token'),
        );
      } catch (e) {
        if (e is ParseException) rethrow;
        throw ParseException(
          message: 'Failed to parse refreshToken response: $e',
          originalError: e,
        );
      }
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

  @override
  Future<TeacherVerificationStatusModel> getTeacherVerificationStatus(
    String token,
  ) async {
    LogHandler.separator(title: 'AUTH REMOTE · TEACHER VERIFICATION STATUS');
    final response = await _apiHandler.get(
      url: ApiConfig.authTeacherVerificationStatus,
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess) {
      final data = _parseMap(response.data, 'response.data');
      return TeacherVerificationStatusModel.fromJson(data);
    }

    throw _handleError(response, 'getTeacherVerificationStatus');
  }

  @override
  Future<void> applyForTeacher(
    String token,
    ApplyTeacherRequest request,
  ) async {
    LogHandler.separator(title: 'AUTH REMOTE · APPLY TEACHER');
    final response = await _apiHandler.post(
      url: ApiConfig.authApplyTeacher,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );

    if (!response.isSuccess) {
      throw _handleError(response, 'applyForTeacher');
    }
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

  /// Safe type casting helpers to prevent runtime errors
  Map<String, dynamic> _parseMap(dynamic value, String fieldName) {
    if (value == null) {
      throw ParseException(
        message: 'Expected Map for "$fieldName" but received null',
      );
    }
    if (value is! Map<String, dynamic>) {
      throw ParseException(
        message:
            'Expected Map<String, dynamic> for "$fieldName" but received ${value.runtimeType}',
      );
    }
    return value;
  }

  String _parseString(dynamic value, String fieldName) {
    if (value == null) {
      throw ParseException(
        message: 'Expected String for "$fieldName" but received null',
      );
    }
    if (value is! String) {
      throw ParseException(
        message:
            'Expected String for "$fieldName" but received ${value.runtimeType}',
      );
    }
    if (value.isEmpty) {
      throw ParseException(
        message:
            'Expected non-empty String for "$fieldName" but received empty string',
      );
    }
    return value;
  }
}
