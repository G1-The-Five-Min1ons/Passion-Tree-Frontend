import 'dart:convert';
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

enum LogLevel { debug, info, request, response, success, error, warning }
class LogHandler {
  static bool _enabled = kDebugMode;
  static bool _useColors = true;
  static bool _debugEnabled = false;

  static void setEnabled(bool enabled) => _enabled = enabled;
  static void setUseColors(bool useColors) => _useColors = useColors;
  static void setDebugEnabled(bool enabled) => _debugEnabled = enabled;

  /// Internal central logging method
  static void _log(LogLevel level, String prefix, String message, {Object? error, StackTrace? stackTrace}) {
    if (!_enabled) return;
    if (level == LogLevel.debug && !_debugEnabled) return;

    final timestamp = _timestamp();
    final color = _getColor(level);
    final reset = _useColors ? _AnsiColors.reset : '';

    debugPrint('$color$timestamp [$prefix] : $message$reset');

    if (error != null) {
      debugPrint('$color$timestamp Details : $error$reset');
    }

    if (stackTrace != null) {
      debugPrint('$color$timestamp StackTrace :\n$stackTrace$reset');
    }
  }

  static void debug(String message) => _log(LogLevel.debug, 'DEBUG', message);
  
  static void info(String message) => _log(LogLevel.info, 'INFO', message);
  
  static void success(String message) => _log(LogLevel.success, 'SUCCESS', message);
  
  static void warning(String message) => _log(LogLevel.warning, 'WARNING', message);
  
  static void error(String message, {Object? error, StackTrace? stackTrace}) => 
      _log(LogLevel.error, 'ERROR', message, error: error, stackTrace: stackTrace);

  static void apiError({
    required String method,
    required String url,
    required int statusCode,
    String? message,
  }) {
    final isWarning = statusCode >= 400 && statusCode < 500;
    final level = isWarning ? LogLevel.warning : LogLevel.error;
    final prefix = isWarning ? 'API-WARN' : 'API-ERROR';

    _log(level, prefix, '$method $url ($statusCode) : ${message ?? "Request failed"}');
  }

  static void request({
    required String method,
    required String url,
    dynamic body,
  }) {
    _log(LogLevel.request, 'REQUEST', '[$method] : $url');
    if (body != null && _debugEnabled) {
      debugPrint('${_getColor(LogLevel.request)}Body: ${_prettyJson(body)}${_AnsiColors.reset}');
    }
  }

  static void response({
    required String method,
    required String url,
    required int statusCode,
    dynamic data,
  }) {
    _log(LogLevel.response, 'RESPONSE', '<$statusCode>-[$method] : $url');
    if (data != null && _debugEnabled) {
      debugPrint('${_getColor(LogLevel.response)}JSON: ${_prettyJson(data)}${_AnsiColors.reset}');
    }
  }

  static void separator({String? title}) {
    if (!_enabled) return;
    final color = _useColors ? _AnsiColors.magenta : '';
    final reset = _useColors ? _AnsiColors.reset : '';
    final bar = '=' * 60;

    debugPrint('\n$color$bar$reset');
    if (title != null) {
      debugPrint('$color${title.toUpperCase()}$reset');
      debugPrint('$color$bar$reset');
    }
  }

  static String _timestamp() {
    final now = DateTime.now();
    return '[${now.hour.toString().padLeft(2, '0')}:'
           '${now.minute.toString().padLeft(2, '0')}:'
           '${now.second.toString().padLeft(2, '0')}.'
           '${now.millisecond.toString().padLeft(3, '0')}]';
  }

  static String _getColor(LogLevel level) {
    if (!_useColors) return '';
    switch (level) {
      case LogLevel.debug: return _AnsiColors.magenta;
      case LogLevel.info: return _AnsiColors.brightCyan;
      case LogLevel.request: return _AnsiColors.brightBlue;
      case LogLevel.response: return _AnsiColors.magenta;
      case LogLevel.success: return _AnsiColors.brightGreen;
      case LogLevel.error: return _AnsiColors.brightRed;
      case LogLevel.warning: return _AnsiColors.brightYellow;
    }
  }

  static String _prettyJson(dynamic json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      if (json is Map || json is List) return encoder.convert(json);
      final decoded = jsonDecode(json.toString());
      return encoder.convert(decoded);
    } catch (_) {
      return json.toString();
    }
  }
}