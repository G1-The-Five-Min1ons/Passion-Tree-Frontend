class ApiConfig {
  static const String apiBaseUrl = 'http://10.0.2.2:5000'; 
  static const String _devAIUrl = 'http://10.0.2.2:8000'; 
  
  // Auto-detect environment (or use --dart-define for build)
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: apiBaseUrl,
  );
  
  static const String aiBaseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: _devAIUrl,
  );
  
  // API version
  static const String apiVersion = '/api/v1';
  static String get apiBackendUrl => '$backendBaseUrl$apiVersion';
  static String get apiAIUrl => '$aiBaseUrl$apiVersion';
  
  static String get authRegister => '$apiBackendUrl/auth/register';
  static String get authLogin => '$apiBackendUrl/auth/login';
  static String get authVerifyEmail => '$apiBackendUrl/auth/verify-email';
  static String get authResendVerification => '$apiBackendUrl/auth/resend-verification';
  static String get authForgotPassword => '$apiBackendUrl/auth/forgot-password';
  static String get authResetPassword => '$apiBackendUrl/auth/reset-password';
  static String get authGetProfile => '$apiBackendUrl/auth/profile';
  static String get authUpdateProfile => '$apiBackendUrl/auth/profile';
  static String get authUpdateUser => '$apiBackendUrl/auth/user';
  static String get authChangePassword => '$apiBackendUrl/auth/change-password';
  static String get authDeleteUser => '$apiBackendUrl/auth/user';
  
  static String get learningPaths => '$apiBackendUrl/learningpaths';
  static String get reflection => '$apiBackendUrl/reflection';
  
  static String get aiSearch => '$apiAIUrl/learningpaths/search';
  static String get aiRecommendation => '$apiAIUrl/recommendation';
  
  // Timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Default headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  /// Get authenticated headers with JWT token
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
