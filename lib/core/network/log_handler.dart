import 'package:flutter/foundation.dart';

/// ANSI color codes for terminal output
class _AnsiColors {
  static const String reset = '\x1B[0m';
  static const String magenta = '\x1B[35m';
  static const String brightRed = '\x1B[91m';
  static const String brightGreen = '\x1B[92m';
  static const String brightYellow = '\x1B[93m';
  static const String brightBlue = '\x1B[94m';
  static const String brightCyan = '\x1B[96m';
}

/// Log levels with corresponding colors
enum LogLevel { debug, info, request, response, success, error, warning }

/// Custom logger for API and general application logging
class LogHandler {
  static bool _enabled = kDebugMode;
  static bool _useColors = true;
  static bool _debugEnabled = false;

  /// Enable or disable logging
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Enable or disable colored output
  static void setUseColors(bool useColors) {
    _useColors = useColors;
  }

  /// Enable or disable verbose debug logging.
  /// Set to true when you need detailed step-by-step logs for troubleshooting.
  static void setDebugEnabled(bool enabled) {
    _debugEnabled = enabled;
  }

  /// Get current timestamp in HH:mm:ss.SSS format
  static String _timestamp() {
    final now = DateTime.now();
    return '[${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}]';
  }

  /// Get color for log level
  static String _getColor(LogLevel level) {
    if (!_useColors) return '';

    switch (level) {
      case LogLevel.debug:
        return _AnsiColors.magenta;
      case LogLevel.info:
        return _AnsiColors.brightCyan;
      case LogLevel.request:
        return _AnsiColors.brightBlue;
      case LogLevel.response:
        return _AnsiColors.magenta;
      case LogLevel.success:
        return _AnsiColors.brightGreen;
      case LogLevel.error:
        return _AnsiColors.brightRed;
      case LogLevel.warning:
        return _AnsiColors.brightYellow;
    }
  }

  /// Log verbose debug message (only shown when debugEnabled is true)
  static void debug(String message) {
    if (!_enabled || !_debugEnabled) return;

    final timestamp = _timestamp();
    final color = _getColor(LogLevel.debug);
    final reset = _useColors ? _AnsiColors.reset : '';

    debugPrint('$color$timestamp [DEBUG] : $message$reset');
  }

  /// Log info message
  static void info(String message) {
    if (!_enabled) return;

    final timestamp = _timestamp();
    final color = _getColor(LogLevel.info);
    final reset = _useColors ? _AnsiColors.reset : '';

    debugPrint('$color$timestamp [INFO] : $message$reset');
  }

  /// Log API request
  static void request({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (!_enabled) return;

    final timestamp = _timestamp();
    final color = _getColor(LogLevel.request);
    final reset = _useColors ? _AnsiColors.reset : '';

    debugPrint('$color$timestamp [REQUEST] [$method] : $url$reset');

    // if (body != null) {
    //   debugPrint('$color$timestamp Body : ${_prettyJson(body)}$reset');
    // }
  }

  /// Log API response
  static void response({
    required String method,
    required String url,
    required int statusCode,
    dynamic data,
  }) {
    if (!_enabled) return;

    final timestamp = _timestamp();
    final color = _getColor(LogLevel.response);
    final reset = _useColors ? _AnsiColors.reset : '';

    debugPrint(
      '$color$timestamp [RESPONSE] <$statusCode>-[$method] : $url$reset',
    );

  }

  /// Log success message
  static void success(String message) {
    if (!_enabled) return;

    final timestamp = _timestamp();
    final color = _getColor(LogLevel.success);
    final reset = _useColors ? _AnsiColors.reset : '';

    debugPrint('$color$timestamp [SUCCESS] : $message$reset');
  }

  /// Log error message
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (!_enabled) return;

    final timestamp = _timestamp();
    final color = _getColor(LogLevel.error);
    final reset = _useColors ? _AnsiColors.reset : '';

    debugPrint('$color$timestamp [ERROR] : $message$reset');

    if (error != null) {
      debugPrint('$color$timestamp Error Details : $error$reset');
    }

    if (stackTrace != null) {
      debugPrint('$color$timestamp StackTrace :\n$stackTrace$reset');
    }
  }

  /// Log warning message
  static void warning(String message) {
    if (!_enabled) return;

    final timestamp = _timestamp();
    final color = _getColor(LogLevel.warning);
    final reset = _useColors ? _AnsiColors.reset : '';

    debugPrint('$color$timestamp [WARNING] : $message$reset');
  }

  // static String _prettyJson(dynamic json) {
  //   try {
  //     const encoder = JsonEncoder.withIndent('  ');
  //     if (json is String) {
  //       try {
  //         final decoded = jsonDecode(json);
  //         return encoder.convert(decoded);
  //       } catch (_) {
  //         return json;
  //       }
  //       return encoder.convert(json);
  //     } catch (e) {
  //       return json.toString();
  //     }
  // }

  /// Log section separator
  static void separator({String? title}) {
    if (!_enabled) return;

    final color = _useColors
        ? _AnsiColors.magenta
        : ''; // Using magenta as fallback for gray
    final reset = _useColors ? _AnsiColors.reset : '';

    if (title != null) {
      debugPrint('$color${'=' * 60}$reset');
      debugPrint('$color$title$reset');
      debugPrint('$color${'=' * 60}$reset');
    } else {
      debugPrint('$color${'=' * 60}$reset');
    }
  }
}
