import 'dart:async';
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
  final bool isTokenExpired;

  /// Full raw JSON body - used when backend puts fields at root level instead of under 'data'
  final Map<String, dynamic>? rawBody;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    required this.statusCode,
    this.isTokenExpired = false,
    this.rawBody,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
    int statusCode,
  ) {
    bool isExpired = false;
    if (statusCode == 401) {
      final errorStr = (json['error'] as String?)?.toLowerCase() ?? '';
      // Matches the backend output "invalid or expired token"
      if (errorStr.contains('expired') || errorStr.contains('token')) {
        isExpired = true;
      }
    }

    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      error: json['error'] as String?,
      statusCode: statusCode,
      isTokenExpired: isExpired,
      rawBody:
          json, // Store the complete JSON so callers can access root-level fields
    );
  }

  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
  bool get isError => !success || statusCode >= 400;
}

/// Callback for when a token needs refreshing.
/// Should return true if successful, false if the refresh failed (e.g. refresh token expired).
typedef RefreshTokenCallback = Future<bool> Function();

/// Callback to get the current access token
typedef GetTokenCallback = Future<String?> Function();

/// API Handler for HTTP requests with logging and silent refresh support
class ApiHandler {
  final http.Client _client;

  // Callbacks for token management
  RefreshTokenCallback? onTokenRefresh;
  GetTokenCallback? getToken;

  // State for handling concurrent refreshes
  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshQueue = [];

  ApiHandler({http.Client? client, this.onTokenRefresh, this.getToken})
    : _client = client ?? http.Client();

  /// Wait if a token refresh is currently in progress
  Future<void> _waitForRefresh() async {
    if (!_isRefreshing) return;

    LogHandler.info('ApiHandler: Request waiting for token refresh...');
    final completer = Completer<bool>();
    _refreshQueue.add(completer);
    final success = await completer.future;

    if (!success) {
      throw AuthException(
        message: 'Token refresh failed while waiting',
        statusCode: 401,
      );
    }
  }

  /// Internal wrapper to handle 401s and retries
  Future<ApiResponse<T>> _requestWithRetry<T>({
    required String method,
    required String url,
    required Future<http.Response> Function(Map<String, String>? headers)
    performRequest,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    // 1. Wait if we're currently refreshing
    await _waitForRefresh();

    // 2. Perform the initial request
    ApiResponse<T> response = await _executeRequest(
      method,
      url,
      performRequest,
      headers,
      fromJson,
    );

    // 3. If 401 and we have a refresh callback, try to refresh
    if (response.statusCode == 401 &&
        response.isTokenExpired &&
        onTokenRefresh != null) {
      LogHandler.warning(
        'ApiHandler: Received 401 for $method $url. Token might be expired.',
      );

      if (_isRefreshing) {
        // Someone else started the refresh while we were executing. Wait for them.
        await _waitForRefresh();
      } else {
        // We are the first to get the 401. Start the refresh process.
        _isRefreshing = true;
        LogHandler.info('ApiHandler: Starting silent token refresh...');

        bool refreshSuccess = false;
        try {
          refreshSuccess = await onTokenRefresh!();
        } catch (e) {
          LogHandler.error(
            'ApiHandler: Token refresh threw an exception',
            error: e,
          );
          refreshSuccess = false;
        }

        _isRefreshing = false;

        // Notify waiting requests
        for (var completer in _refreshQueue) {
          completer.complete(refreshSuccess);
        }
        _refreshQueue.clear();

        if (!refreshSuccess) {
          LogHandler.error('ApiHandler: Token refresh failed. Logging out...');
          return response; // Return the original 401 response
        }
      }

      // 4. If refresh succeeded, we need to update the Authorization header and retry
      LogHandler.info(
        'ApiHandler: Token refreshed successfully. Retrying request: $method $url',
      );
      Map<String, String> retryHeaders = Map.from(headers ?? {});
      if (getToken != null) {
        final newToken = await getToken!();
        if (newToken != null) {
          retryHeaders['Authorization'] = 'Bearer $newToken';
        }
      }

      response = await _executeRequest(
        method,
        url,
        performRequest,
        retryHeaders,
        fromJson,
      );
    }

    return response;
  }

  /// Execute a single HTTP request without retry logic
  Future<ApiResponse<T>> _executeRequest<T>(
    String method,
    String url,
    Future<http.Response> Function(Map<String, String>? headers) performRequest,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final response = await performRequest(headers);
      return _handleResponse<T>(response, fromJson, method, url);
    } catch (e, stackTrace) {
      return _handleError<T>(e, stackTrace, method, url);
    }
  }

  /// Make GET request
  Future<ApiResponse<T>> get<T>({
    required String url,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    LogHandler.request(method: 'GET', url: url);
    return _requestWithRetry<T>(
      method: 'GET',
      url: url,
      headers: headers,
      fromJson: fromJson,
      performRequest: (reqHeaders) =>
          _client.get(Uri.parse(url), headers: reqHeaders).timeout(timeout),
    );
  }

  /// Make POST request
  Future<ApiResponse<T>> post<T>({
    required String url,
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? fromJson,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    LogHandler.request(method: 'POST', url: url, body: body);
    return _requestWithRetry<T>(
      method: 'POST',
      url: url,
      headers: headers,
      fromJson: fromJson,
      performRequest: (reqHeaders) => _client
          .post(
            Uri.parse(url),
            headers: reqHeaders,
            body: body is String ? body : jsonEncode(body),
          )
          .timeout(timeout),
    );
  }

  /// Make PUT request
  Future<ApiResponse<T>> put<T>({
    required String url,
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? fromJson,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    LogHandler.request(method: 'PUT', url: url, body: body);
    return _requestWithRetry<T>(
      method: 'PUT',
      url: url,
      headers: headers,
      fromJson: fromJson,
      performRequest: (reqHeaders) => _client
          .put(
            Uri.parse(url),
            headers: reqHeaders,
            body: body is String ? body : jsonEncode(body),
          )
          .timeout(timeout),
    );
  }

  /// Make DELETE request
  Future<ApiResponse<T>> delete<T>({
    required String url,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    LogHandler.request(method: 'DELETE', url: url);
    return _requestWithRetry<T>(
      method: 'DELETE',
      url: url,
      headers: headers,
      fromJson: fromJson,
      performRequest: (reqHeaders) =>
          _client.delete(Uri.parse(url), headers: reqHeaders).timeout(timeout),
    );
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
      LogHandler.error('Failed to parse response from $method $url', error: e);

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
