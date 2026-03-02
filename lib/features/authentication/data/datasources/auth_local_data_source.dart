import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> saveUsername(String username);
  Future<String?> getUsername();
  Future<void> saveHeartCount(int heartCount);
  Future<int> getHeartCount();
  Future<void> saveRole(String role);
  Future<String?> getRole();
  Future<bool> hasSelectedRole(String userId);
  Future<void> markRoleSelected(String userId);
  Future<bool> isLoggedIn();
  Future<void> clearAuth();
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _heartCountKey = 'heart_count';
  static const String _roleKey = 'user_role';
  static const String _roleSelectedPrefix = 'has_selected_role_';

  final FlutterSecureStorage _secureStorage;

  AuthLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  @override
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  @override
  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  @override
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  @override
  Future<void> saveHeartCount(int heartCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_heartCountKey, heartCount);
  }

  @override
  Future<int> getHeartCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_heartCountKey) ?? 5;
  }

  @override
  Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  @override
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  @override
  Future<bool> hasSelectedRole(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_roleSelectedPrefix$userId') ?? false;
  }

  @override
  Future<void> markRoleSelected(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_roleSelectedPrefix$userId', true);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearAuth() async {
    // Clear sensitive tokens from secure storage
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    
    // Clear general user data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_heartCountKey);
    await prefs.remove(_roleKey);
  }

  @override
  Future<void> clearAll() async {
    // Clear all secure storage
    await _secureStorage.deleteAll();
    
    // Clear all SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
