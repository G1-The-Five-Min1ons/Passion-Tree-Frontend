class ErrorUtils {
  static String extractErrorMessage(Object error) {
    String errorMessage = error.toString();
    if (errorMessage.startsWith('Exception: ')) {
      return errorMessage.substring(11);
    }
    return errorMessage;
  }
}
