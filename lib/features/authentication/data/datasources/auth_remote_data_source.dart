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
import 'package:passion_tree_frontend/features/authentication/data/models/profile_response.dart';
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
  Future<ProfileResponse> getProfile(String token);
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

  /// Generic helper method to execute requests and parse responses
  /// Returns parsed response of type [T] or throws exception
  Future<T> _executeRequest<T>({
    required String logTitle,
    required Future<ApiResponse> Function() apiCall,
    required T Function(ApiResponse response) onSuccess,
    required String context,
    int? expectedStatusCode,
  }) async {
    LogHandler.separator(title: logTitle);
    final response = await apiCall();
    
    if (response.isSuccess && 
        (expectedStatusCode == null || response.statusCode == expectedStatusCode)) {
      LogHandler.success('$context successful');
      return onSuccess(response);
    }
    
    throw _handleError(response, context);
  }

  /// Generic helper for OAuth sign-in operations (Google, Discord, etc.)
  Future<T> _handleOAuthSignIn<T>({
    required String url,
    required Map<String, dynamic> requestBody,
    required String logTitle,
    required String context,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return _executeRequest<T>(
      logTitle: logTitle,
      context: context,
      apiCall: () => _apiHandler.post(
        url: url,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(requestBody),
        timeout: ApiConfig.connectionTimeout,
      ),
      onSuccess: (response) {
        final fullBody = _parseMap(response.rawBody, 'rawBody');
        LogHandler.info('Raw Backend Response: $fullBody');
        LogHandler.info('Token: ${fullBody['token']}');
        LogHandler.info('Data: ${fullBody['data']}');
        final raw = <String, dynamic>{
          'success': response.success,
          'token': _parseString(fullBody['token'], 'token'),
          'data': fullBody['data'],
        };
        LogHandler.info('Constructed raw object: $raw');
        return fromJson(raw);
      },
    );
  }

  @override
  Future<RegisterResponse> register(RegisterRequest request) async {
    return _executeRequest<RegisterResponse>(
      logTitle: 'AUTH REMOTE · REGISTER',
      context: 'register',
      expectedStatusCode: 201,
      apiCall: () => _apiHandler.post(
        url: ApiConfig.authRegister,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(request.toJson()),
        timeout: ApiConfig.connectionTimeout,
      ),
      onSuccess: (response) {
        final raw = <String, dynamic>{
          'success': response.success,
          'message': response.message,
          'data': response.data,
        };
        return RegisterResponse.fromJson(raw);
      },
    );
  }

  @override
  Future<LoginOtpResponse> login(LoginRequest request, {bool? confirmReactivate}) {
    return _executeRequest<LoginOtpResponse>(
      logTitle: 'AUTH REMOTE · LOGIN',
      context: 'login',
      apiCall: () => _apiHandler.post(
        url: ApiConfig.authLogin,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(request.toJson()),
        timeout: ApiConfig.connectionTimeout,
      ),
      onSuccess: (response) => LoginOtpResponse(
        success: response.success,
        message: response.message ?? '',
      ),
    );
  }

  @override
  Future<VerifyEmailResponse> verifyEmail(VerifyEmailRequest request) async {
    return _executeRequest<VerifyEmailResponse>(
      logTitle: 'AUTH REMOTE · VERIFY EMAIL',
      context: 'verifyEmail',
      apiCall: () => _apiHandler.post(
        url: ApiConfig.authVerifyEmail,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(request.toJson()),
        timeout: ApiConfig.connectionTimeout,
      ),
      onSuccess: (response) {
        final data = _parseMap(response.data, 'response.data');
        return VerifyEmailResponse(
          success: true,
          message: response.message ?? '',
          accessToken: _parseString(data['access_token'], 'access_token'),
          refreshToken: _parseString(data['refresh_token'], 'refresh_token'),
        );
      },
    );
  }

  @override
  Future<void> resendVerificationEmail(
    ResendVerificationRequest request,
  ) async {
    return _executeRequest<void>(
      logTitle: 'AUTH REMOTE · RESEND VERIFICATION',
      context: 'resendVerification',
      apiCall: () => _apiHandler.post(
        url: ApiConfig.authResendVerification,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(request.toJson()),
        timeout: ApiConfig.connectionTimeout,
      ),
      onSuccess: (_) {},
    );
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    return _executeRequest<void>(
      logTitle: 'AUTH REMOTE · FORGOT PASSWORD',
      context: 'forgotPassword',
      apiCall: () => _apiHandler.post(
        url: ApiConfig.authForgotPassword,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(request.toJson()),
        timeout: ApiConfig.connectionTimeout,
      ),
      onSuccess: (_) {},
    );
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    return _executeRequest<void>(
      logTitle: 'AUTH REMOTE · RESET PASSWORD',
      context: 'resetPassword',
      apiCall: () => _apiHandler.post(
        url: ApiConfig.authResetPassword,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(request.toJson()),
        timeout: ApiConfig.connectionTimeout,
      ),
      onSuccess: (_) {},
    );
  }

  @override
  Future<ProfileResponse> getProfile(String token) async {
    return _executeRequest<ProfileResponse>(
      logTitle: 'AUTH REMOTE · GET PROFILE',
      context: 'getProfile',
      apiCall: () => _apiHandler.get(
        url: ApiConfig.authGetProfile,
        headers: ApiConfig.getAuthHeaders(token),
        timeout: ApiConfig.connectionTimeout,
      ),
      onSuccess: (response) {
        final raw = <String, dynamic>{
          'success': response.success,
          'message': response.message,
          'data': response.data,
        };
        return ProfileResponse.fromJson(raw);
      },
    );
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
    return _executeRequest<void>(
      logTitle: 'AUTH REMOTE · CHANGE PASSWORD',
      context: 'changePassword',
      apiCall: () => _apiHandler.put(
        url: ApiConfig.authChangePassword,
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(request.toJson()),
        timeout: ApiConfig.connectionTimeout,
      ),
      onSuccess: (_) {},
    );
  }

  @override
  Future<void> deleteUser(String token, String password) async {
    return _executeRequest<void>(
      logTitle: 'AUTH REMOTE · DELETE USER',
      context: 'deleteUser',
      apiCall: () => _apiHandler.delete(
        url: ApiConfig.authDeleteUser,
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode({'password': password}),
      timeout: ApiConfig.connectionTimeout,
      ),
      onSuccess: (_) {},
    );
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
    return _handleOAuthSignIn<NativeGoogleSignInResponse>(
      url: ApiConfig.authNativeGoogleSignIn,
      requestBody: {'id_token': idToken},
      logTitle: 'AUTH REMOTE · NATIVE GOOGLE SIGN-IN',
      context: 'nativeGoogleSignIn',
      fromJson: (json) => NativeGoogleSignInResponse.fromJson(json),
    );
  }

  @override
  Future<NativeDiscordSignInResponse> nativeDiscordSignIn(String code) async {
    return _handleOAuthSignIn<NativeDiscordSignInResponse>(
      url: ApiConfig.authNativeDiscordSignIn,
      requestBody: {'code': code},
      logTitle: 'AUTH REMOTE · NATIVE DISCORD SIGN-IN',
      context: 'nativeDiscordSignIn',
      fromJson: (json) => NativeDiscordSignInResponse.fromJson(json),
    );
  }

  @override
  Future<VerifyEmailResponse> refreshToken(String refreshTokenValue) async {
    return _executeRequest<VerifyEmailResponse>(
      logTitle: 'AUTH REMOTE · REFRESH TOKEN',
      context: 'refreshToken',
      apiCall: () => _apiHandler.post(
        url: ApiConfig.authRefreshToken,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'refresh_token': refreshTokenValue}),
        timeout: ApiConfig.connectionTimeout,
      ),
      onSuccess: (response) {
        final data = _parseMap(response.data, 'response.data');
        return VerifyEmailResponse(
          success: true,
          message: response.message ?? '',
          accessToken: _parseString(data['access_token'], 'access_token'),
          refreshToken: _parseString(data['refresh_token'], 'refresh_token'),
        );
      },
    );
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
    return _executeRequest<void>(
      logTitle: 'AUTH REMOTE · SELECT ROLE',
      context: 'selectRole',
      apiCall: () => _apiHandler.put(
        url: ApiConfig.authUpdateUser,
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(request.toJson()),
        timeout: ApiConfig.connectionTimeout,
      ),
      onSuccess: (_) {},
    );
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
      if (errorLower.contains('verification_required') ||
          errorLower.contains('6-digit code') ||
          errorLower.contains('otp')) {
        return backendError;
      }
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
