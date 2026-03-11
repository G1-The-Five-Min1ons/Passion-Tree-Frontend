import 'package:google_sign_in/google_sign_in.dart';
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/core/network/api_handler.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/register_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/login_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/verify_email_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/resend_verification_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/forgot_password_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/reset_password_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/change_password_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/select_role_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/update_user_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/update_profile_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/apply_teacher_request.dart';
import 'package:passion_tree_frontend/features/authentication/data/mappers/auth_mapper.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/user_profile.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/user.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/teacher_verification_status.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final ApiHandler _apiHandler;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required ApiHandler apiHandler,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _apiHandler = apiHandler {
    // Initialize logic moved to signInWithGoogle method

    // Inject token refresh logic into the shared ApiHandler
    _apiHandler.getToken = () => _localDataSource.getToken();
    _apiHandler.onTokenRefresh = _handleTokenRefresh;
  }

  /// Handles the silent token refresh flow
  Future<bool> _handleTokenRefresh() async {
    try {
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _remoteDataSource.refreshToken(refreshToken);
      await _localDataSource.saveToken(response.accessToken);
      await _localDataSource.saveRefreshToken(response.refreshToken);
      return true;
    } catch (e) {
      // If refresh fails (e.g., token expired), clear auth to force logout
      await _localDataSource.clearAuth();
      return false;
    }
  }

  /// Generic helper method for OAuth login operations
  Future<UserProfile> _handleOAuthLogin({
    required String token,
    required String userId,
    required String username,
    required String role,
    required String email,
    required String firstName,
    required String lastName,
    required String logContext,
  }) async {
    LogHandler.info('$logContext: Saving authentication data...');
    await _localDataSource.saveToken(token);
    await _localDataSource.saveUserId(userId);
    await _localDataSource.saveUsername(username);
    await _localDataSource.saveRole(role);

    // Try to fetch full profile, but don't let it block login
    try {
      LogHandler.info('$logContext: Fetching user profile...');
      final profile = await getProfile();
      LogHandler.success('$logContext: Profile fetched successfully');
      return profile;
    } catch (e) {
      LogHandler.error('$logContext: getProfile failed (non-fatal): $e');
      // Return a minimal UserProfile from the sign-in response data
      final now = DateTime.now();
      return UserProfile(
        user: User(
          userId: userId,
          username: username,
          email: email,
          firstName: firstName,
          lastName: lastName,
          role: role,
          heartCount: 0,
          isEmailVerified: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  @override
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
  }) async {
    LogHandler.info(
      'AuthRepository: Attempting manual registration for $email',
    );
    final request = RegisterRequest(
      username: username,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: role,
      bio: bio,
      location: location,
      avatarUrl: avatarUrl,
    );
    final response = await _remoteDataSource.register(request);
    LogHandler.success(
      'AuthRepository: Manual registration successful for user ${response.userId}',
    );
    return response.userId;
  }

  @override
  Future<String> login({
    required String identifier,
    required String password,
  }) async {
    LogHandler.info('AuthRepository: Attempting login for $identifier');
    final request = LoginRequest(identifier: identifier, password: password);
    final response = await _remoteDataSource.login(request);
    LogHandler.success('AuthRepository: Login successful');
    return response.message;
  }

  @override
  Future<void> verifyEmail(String code) async {
    final request = VerifyEmailRequest(code: code);
    final response = await _remoteDataSource.verifyEmail(request);
    await _localDataSource.saveToken(response.accessToken);
    await _localDataSource.saveRefreshToken(response.refreshToken);
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    final request = ResendVerificationRequest(email: email);
    await _remoteDataSource.resendVerificationEmail(request);
  }

  @override
  Future<void> forgotPassword(String email) async {
    final request = ForgotPasswordRequest(email: email);
    await _remoteDataSource.forgotPassword(request);
  }

  @override
  Future<void> resetPassword(String code, String newPassword) async {
    final request = ResetPasswordRequest(code: code, newPassword: newPassword);
    await _remoteDataSource.resetPassword(request);
  }

  @override
  Future<UserProfile> getProfile() async {
    final token = await _localDataSource.getToken();
    if (token == null) throw Exception('No token found');

    final profileResponse = await _remoteDataSource.getProfile(token);

    // Convert models to entities
    final user = AuthMapper.toUserEntity(profileResponse.user);
    final profile = profileResponse.profile != null
        ? AuthMapper.toProfileEntity(profileResponse.profile!)
        : null;

    final userProfile = UserProfile(user: user, profile: profile);

    // Cache user data locally
    await _localDataSource.saveUserId(userProfile.user.userId);
    await _localDataSource.saveUsername(userProfile.user.username);
    await _localDataSource.saveRole(userProfile.user.role);
    await _localDataSource.saveHeartCount(userProfile.user.heartCount);

    return userProfile;
  }

  @override
  Future<void> updateAccountSettings({
    required String username,
    required String firstName,
    required String lastName,
    String? location,
    String? bio,
    String? avatarUrl,
    String? phoneNumber,
  }) async {
    final token = await _localDataSource.getToken();
    if (token == null) throw Exception('No token found');

    final userRequest = UpdateUserRequest(
      username: username,
      firstName: firstName,
      lastName: lastName,
    );

    final profileRequest = UpdateProfileRequest(
      location: location,
      bio: bio,
      avatarUrl: avatarUrl,
      phoneNumber: phoneNumber,
    );

    await _remoteDataSource.updateUser(token, userRequest);
    await _remoteDataSource.updateProfile(token, profileRequest);

    await _localDataSource.saveUsername(username);
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final token = await _localDataSource.getToken();
    if (token == null) throw Exception('No token found');
    final request = ChangePasswordRequest(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    await _remoteDataSource.changePassword(token, request);
  }

  @override
  Future<void> deleteUser() async {
    final token = await _localDataSource.getToken();
    if (token == null) throw Exception('No token found');
    await _remoteDataSource.deleteUser(token);
    await _localDataSource.clearAuth();
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearAuth();
  }

  @override
  Future<UserProfile> nativeGoogleSignIn(String idToken) async {
    LogHandler.info('AuthRepository: Starting nativeGoogleSignIn with backend...');
    final response = await _remoteDataSource.nativeGoogleSignIn(idToken);
    LogHandler.success('AuthRepository: Backend returned success');
    
    return _handleOAuthLogin(
      token: response.token,
      userId: response.userId,
      username: response.username,
      role: response.role,
      email: '',
      firstName: '',
      lastName: '',
      logContext: 'AuthRepository (Google)',
    );
  }

  @override
  Future<UserProfile> nativeDiscordSignIn(String code) async {
    LogHandler.info('AuthRepository: Starting nativeDiscordSignIn with backend code...');
    final response = await _remoteDataSource.nativeDiscordSignIn(code);
    LogHandler.success('AuthRepository: Backend returned success');

    return _handleOAuthLogin(
      token: response.token,
      userId: response.userId,
      username: response.username,
      role: response.role,
      email: response.email,
      firstName: response.firstName,
      lastName: response.lastName,
      logContext: 'AuthRepository (Discord)',
    );
  }

  @override
  Future<bool> hasSelectedRole() async {
    final userId = await _localDataSource.getUserId();
    if (userId == null) return false;
    return await _localDataSource.hasSelectedRole(userId);
  }

  @override
  Future<void> markRoleSelected() async {
    final userId = await _localDataSource.getUserId();
    if (userId != null) {
      await _localDataSource.markRoleSelected(userId);
    }
  }

  @override
  Future<void> saveUserRole(String role) async {
    await _localDataSource.saveRole(role);
  }

  @override
  Future<void> selectRole(String role) async {
    final token = await _localDataSource.getToken();
    if (token == null) throw Exception('No token found');
    final request = SelectRoleRequest(role: role);
    await _remoteDataSource.selectRole(token, request);
    await _localDataSource.saveRole(role);
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _localDataSource.isLoggedIn();
  }

  @override
  Future<String?> getUserId() async {
    return await _localDataSource.getUserId();
  }

  @override
  Future<String?> getUsername() async {
    return await _localDataSource.getUsername();
  }

  @override
  Future<String?> getUserRole() async {
    return await _localDataSource.getRole();
  }

  @override
  Future<int> getHeartCount() async {
    return await _localDataSource.getHeartCount();
  }

  @override
  Future<void> clearAuth() async {
    await _localDataSource.clearAuth();
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      LogHandler.info(
        'AuthRepository: Initializing Google Sign-In instance...',
      );
      // Initialize Google Sign-In
      await GoogleSignIn.instance.initialize(
        serverClientId: ApiConfig.googleWebClientId,
      );

      LogHandler.info(
        'AuthRepository: Prompting user with Google Sign-In dialog...',
      );
      // Trigger Google Sign-In flow
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate();

      LogHandler.info(
        'AuthRepository: User selected Google Account. Extracting tokens...',
      );
      // Get authentication tokens
      final GoogleSignInAuthentication auth = account.authentication;

      if (auth.idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      LogHandler.info(
        'AuthRepository: Google ID token received. Sending to Passion-Tree Backend...',
      );
      // Send ID token to backend for verification and login
      await nativeGoogleSignIn(auth.idToken!);
    } catch (e) {
      LogHandler.error('Google Sign-In failed: $e');

      // Sign out from Google to allow re-authentication
      await GoogleSignIn.instance.signOut();
      rethrow;
    }
  }

  @override
  Future<void> signInWithDiscord(String code) async {
    // Exchange authorization code with backend for token
    await nativeDiscordSignIn(code);
  }

  @override
  Future<TeacherVerificationStatus> getTeacherVerificationStatus() async {
    final token = await _localDataSource.getToken();
    if (token == null) throw Exception('No token found');

    final model = await _remoteDataSource.getTeacherVerificationStatus(token);
    return model.toEntity();
  }

  @override
  Future<void> applyForTeacher({
    required String phoneNumber,
    required String reason,
    required String teachingHistory,
  }) async {
    final token = await _localDataSource.getToken();
    if (token == null) throw Exception('No token found');

    final request = ApplyTeacherRequest(
      phoneNumber: phoneNumber,
      reason: reason,
      teachingHistory: teachingHistory,
    );
    await _remoteDataSource.applyForTeacher(token, request);
  }
}
