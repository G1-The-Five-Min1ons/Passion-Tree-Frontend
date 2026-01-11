class ApiConfig {
  // Change this based on environment
  static const String _devBaseUrl = 'http://localhost:5000';
  static const String _prodBaseUrl = 'https://your-production-domain.com'; // เปลี่ยนเป็น domain จริง
  
  // Auto-detect environment (or use --dart-define for build)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _devBaseUrl, // ใช้ dev เป็น default
  );
  
  // API endpoints
  static const String apiVersion = '/api/v1';
  static String get apiBaseUrl => '$baseUrl$apiVersion';
  
  // Feature endpoints
  static String get learningPaths => '$apiBaseUrl/learningpaths';
  static String get search => '$apiBaseUrl/learningpaths/search';
  static String get auth => '$apiBaseUrl/auth';
  static String get reflection => '$apiBaseUrl/reflection';
  
  // Timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
