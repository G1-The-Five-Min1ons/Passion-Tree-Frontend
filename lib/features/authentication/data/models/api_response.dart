import 'package:passion_tree_frontend/core/error/exceptions.dart';

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    try {
      return ApiResponse(
        success: json['success'] as bool,
        message: json['message'] as String?,
        data: fromJsonT != null && json['data'] != null
            ? fromJsonT(json['data'])
            : json['data'] as T?,
        error: json['error'] as String?,
      );
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse ApiResponse',
        originalError: e,
      );
    }
  }
}
