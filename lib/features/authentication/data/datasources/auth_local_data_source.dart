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

  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  @override
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_heartCountKey);
    await prefs.remove(_roleKey);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
