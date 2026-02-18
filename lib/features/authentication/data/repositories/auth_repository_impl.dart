import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/auth_models.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

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
    return response.userId;
  }

  @override
  Future<String> login({
    required String identifier,
    required String password,
  }) async {
    final request = LoginRequest(identifier: identifier, password: password);
    final response = await _remoteDataSource.login(request);
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
  Future<dynamic> getProfile() async {
    final token = await _localDataSource.getToken();
    if (token == null) throw Exception('No token found');
    
    final responseMap = await _remoteDataSource.getProfile(token);
    final data = responseMap['data'];
    
    // Cache user data if available
    if (data != null && data['user'] != null) {
      final user = data['user'];
      await _localDataSource.saveUserId(user['user_id']);
      await _localDataSource.saveUsername(user['username']);
      await _localDataSource.saveRole(user['role']);
      if (user['heart_count'] != null) {
        await _localDataSource.saveHeartCount(user['heart_count']);
      }
    }
    
    return data;
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final token = await _localDataSource.getToken();
    if (token == null) throw Exception('No token found');
    final request = ChangePasswordRequest(
        oldPassword: oldPassword, newPassword: newPassword);
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
  Future<void> nativeGoogleSignIn(String idToken) async {
    final response = await _remoteDataSource.nativeGoogleSignIn(idToken);
    await _localDataSource.saveToken(response.token);
    // Note: NativeGoogleSignInResponse has user data but not refresh token currently?
    // And what about role?
    // We should save what we can.
    await _localDataSource.saveUserId(response.userId);
    await _localDataSource.saveUsername(response.username);
    await _localDataSource.saveRole(response.role);
  }

  @override
  Future<void> nativeDiscordSignIn(String code) async {
    final response = await _remoteDataSource.nativeDiscordSignIn(code);
    await _localDataSource.saveToken(response.token);
    await _localDataSource.saveUserId(response.userId);
    await _localDataSource.saveUsername(response.username);
    await _localDataSource.saveRole(response.role);
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
}
