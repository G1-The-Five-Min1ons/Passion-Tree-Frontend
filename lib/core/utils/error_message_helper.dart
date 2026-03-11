/// Utility class for cleaning and formatting error messages
class ErrorMessageHelper {
  /// Cleans up error messages by removing common prefixes and extracting the actual message
  /// 
  /// Examples:
  /// - "AuthException: Invalid credentials" → "Invalid credentials"
  /// - "ServerException: Database error" → "Database error"
  static String cleanErrorMessage(String errorString) {
    String cleanMessage = errorString.trim();
    
    // List of common exception prefixes to remove
    const prefixes = [
      'AuthException:',
      'ServerException:',
      'ParseException:',
      'NetworkException:',
      'CacheException:',
      'Exception:',
    ];
    
    for (final prefix in prefixes) {
      if (cleanMessage.startsWith(prefix)) {
        cleanMessage = cleanMessage.substring(prefix.length).trim();
        break;
      }
    }
    
    return cleanMessage;
  }
  
  /// Checks if the error is a user cancellation
  static bool isCancellation(String errorString) {
    final errorLower = errorString.toLowerCase();
    return errorLower.contains('cancelled') ||
        errorLower.contains('canceled') ||
        errorLower.contains('user_cancelled') ||
        errorLower.contains('sign_in_canceled');
  }
  
  /// Checks if the error is a timeout
  static bool isTimeout(String errorString) {
    final errorLower = errorString.toLowerCase();
    return errorLower.contains('timeout') || errorLower.contains('timed out');
  }
  
  /// Checks if the error is about duplicate email/account
  static bool isDuplicateAccount(String errorString) {
    final errorLower = errorString.toLowerCase();
    return errorLower.contains('account with this email already exists') ||
        errorLower.contains('email already exists') ||
        errorLower.contains('already registered');
  }
  
  /// Gets a user-friendly message for OAuth errors
  static String getOAuthErrorMessage(String errorString, String provider) {
    if (isCancellation(errorString)) {
      return 'User cancelled $provider sign-in';
    }
    
    if (isTimeout(errorString)) {
      return '$provider sign-in timed out';
    }
    
    if (isDuplicateAccount(errorString)) {
      return 'An account with this email already exists. Please use web login to link accounts.';
    }
    
    // Clean up the message
    final cleaned = cleanErrorMessage(errorString);
    return '$provider sign-in failed: $cleaned';
  }
}
