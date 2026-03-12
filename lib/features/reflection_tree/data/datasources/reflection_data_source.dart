import 'dart:convert';
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/core/network/api_handler.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/core/error/exceptions.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/models/reflection_api_model.dart';

class ReflectionDataSource {
  final ApiHandler _apiHandler;

  ReflectionDataSource({ApiHandler? apiHandler})
      : _apiHandler = apiHandler ?? ApiHandler();

  /// Create a new reflection
  Future<ReflectionApiModel> createReflection(
      CreateReflectionRequest request, String token) async {
    LogHandler.separator(title: 'REFLECTION · CREATE');
    final response = await _apiHandler.post(
      url: ApiConfig.reflections,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode(request.toJson()),
      timeout: const Duration(seconds: 60), // Longer timeout for AI analysis
    );

    if (response.isSuccess && response.statusCode == 201) {
      LogHandler.success('Reflection created successfully');
      final data = response.data as Map<String, dynamic>;
      return ReflectionApiModel.fromJson(data['data']);
    }

    final msg = response.error ?? response.message ?? 'Failed to create reflection';
    LogHandler.error('Create reflection failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  /// Get reflection by ID
  Future<ReflectionApiModel> getReflectionById(String reflectId, String token) async {
    LogHandler.separator(title: 'REFLECTION · GET BY ID');
    final response = await _apiHandler.get(
      url: ApiConfig.reflectionById(reflectId),
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess) {
      LogHandler.success('Reflection fetched: $reflectId');
      final data = response.data as Map<String, dynamic>;
      return ReflectionApiModel.fromJson(data['data']);
    }

    final msg = response.error ?? response.message ?? 'Failed to get reflection';
    LogHandler.error('Get reflection failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  /// Get all reflections
  Future<List<ReflectionApiModel>> getAllReflections(String token) async {
    LogHandler.separator(title: 'REFLECTION · GET ALL');
    final response = await _apiHandler.get(
      url: ApiConfig.reflections,
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess) {
      final data = response.data as Map<String, dynamic>;
      final reflections = data['data'] as List? ?? [];
      LogHandler.success('Fetched ${reflections.length} reflection(s)');
      return reflections
          .map((reflection) => ReflectionApiModel.fromJson(reflection))
          .toList();
    }

    final msg = response.error ?? response.message ?? 'Failed to get reflections';
    LogHandler.error('Get reflections failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }
}
