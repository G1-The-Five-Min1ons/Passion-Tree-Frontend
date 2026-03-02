import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:passion_tree_frontend/core/error/exceptions.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
    int statusCode,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      error: json['error'] as String?,
      statusCode: statusCode,
    );
  }

  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
  bool get isError => !success || statusCode >= 400;
}

/// API Handler for HTTP requests with logging
class ApiHandler {
  final http.Client _client;

  ApiHandler({http.Client? client}) : _client = client ?? http.Client();

  /// Make GET request
  Future<ApiResponse<T>> get<T>({
    required String url,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    LogHandler.request(
      method: 'GET',
      url: url,
    );

    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson, 'GET', url);
    } catch (e, stackTrace) {
      return _handleError<T>(e, stackTrace, 'GET', url);
    }
  }

  /// Make POST request
  Future<ApiResponse<T>> post<T>({
    required String url,
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? fromJson,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    LogHandler.request(
      method: 'POST',
      url: url,
      body: body,
    );

    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: body is String ? body : jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson, 'POST', url);
    } catch (e, stackTrace) {
      return _handleError<T>(e, stackTrace, 'POST', url);
    }
  }

  /// Make PUT request
  Future<ApiResponse<T>> put<T>({
    required String url,
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? fromJson,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    LogHandler.request(
      method: 'PUT',
      url: url,
      body: body,
    );

    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: headers,
            body: body is String ? body : jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson, 'PUT', url);
    } catch (e, stackTrace) {
      return _handleError<T>(e, stackTrace, 'PUT', url);
    }
  }

  /// Make DELETE request
  Future<ApiResponse<T>> delete<T>({
    required String url,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    LogHandler.request(
      method: 'DELETE',
      url: url,
    );

    try {
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson, 'DELETE', url);
    } catch (e, stackTrace) {
      return _handleError<T>(e, stackTrace, 'DELETE', url);
    }
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
    String method,
    String url,
  ) {
    final statusCode = response.statusCode;
    
    try {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      
      LogHandler.response(
        method: method,
        url: url,
        statusCode: statusCode,
        data: jsonData,
      );

      final apiResponse = ApiResponse<T>.fromJson(
        jsonData,
        fromJson,
        statusCode,
      );

      if (apiResponse.isSuccess) {
        LogHandler.success('$method $url completed successfully');
      } else if (apiResponse.isError) {
        LogHandler.error(
          '$method $url failed: ${apiResponse.error ?? "Unknown error"}',
        );
      }

      return apiResponse;
    } catch (e) {
      LogHandler.error(
        'Failed to parse response from $method $url',
        error: e,
      );

      return ApiResponse<T>(
        success: false,
        error: 'Failed to parse response: $e',
        statusCode: statusCode,
      );
    }
  }

  /// Handle errors
  ApiResponse<T> _handleError<T>(
    Object error,
    StackTrace stackTrace,
    String method,
    String url,
  ) {
    LogHandler.error(
      'Request failed: $method $url',
      error: error,
      stackTrace: stackTrace,
    );

    String errorMessage;
    int statusCode = 0;

    if (error is NetworkException) {
      errorMessage = error.message;
      statusCode = error.statusCode ?? 0;
    } else if (error is TimeoutException) {
      errorMessage = 'Request timeout';
      statusCode = 408;
    } else {
      errorMessage = 'Network error: ${error.toString()}';
    }

    return ApiResponse<T>(
      success: false,
      error: errorMessage,
      statusCode: statusCode,
    );
  }

  /// Close the HTTP client
  void dispose() {
    _client.close();
  }
}
