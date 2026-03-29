import 'dart:convert';

import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/core/error/exceptions.dart';
import 'package:passion_tree_frontend/core/network/api_handler.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/ai_generate_response_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_material_request_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_node_request_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_path_request_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_question_with_choices_request_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/enrolled_learning_path_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_node_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_path_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_path_progress_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/node_detail_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/quiz_question_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_material.dart';

class LearningPathDataSource {
  final ApiHandler _apiHandler;
  final AuthLocalDataSource _authLocalDataSource;

  LearningPathDataSource({
    required ApiHandler apiHandler,
    required AuthLocalDataSource authLocalDataSource,
  })  : _apiHandler = apiHandler,
        _authLocalDataSource = authLocalDataSource;

  /// Get auth headers using the stored token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authLocalDataSource.getToken();
    if (token == null || token.isEmpty) {
      return ApiConfig.defaultHeaders;
    }
    return ApiConfig.getAuthHeaders(token);
  }

  /// Extract user_id from JWT token payload
  Future<String> _getUserIdFromToken() async {
    try {
      final token = await _authLocalDataSource.getToken();
      if (token == null || token.isEmpty) {
        throw AuthException(message: 'No token found', statusCode: 401);
      }
      final parts = token.split('.');
      if (parts.length != 3) {
        throw AuthException(message: 'Invalid token format', statusCode: 401);
      }

      final normalized = base64.normalize(parts[1]);
      final decoded = utf8.decode(base64.decode(normalized));
      final Map<String, dynamic> payload = jsonDecode(decoded);

      final userId = payload['user_id'] ?? payload['sub'];
      if (userId == null) {
        throw AuthException(
          message: 'user_id not found in token payload',
          statusCode: 401,
        );
      }
      return userId.toString();
    } catch (e) {
      LogHandler.error('[DataSource] Error extracting user_id from token: $e');
      rethrow;
    }
  }

  void _throwIfError(ApiResponse response, String context) {
    if (!response.isSuccess) {
      final msg = response.error ?? response.message ?? '$context failed';
      throw createExceptionFromStatusCode(response.statusCode, msg);
    }
  }

  // ── Learning Paths ────────────────────────────────────────────────────────

  Future<List<LearningPathApiModel>> getAllLearningPaths() async {
    final response = await _apiHandler.get(
      url: '${ApiConfig.apiBackendUrl}/learningpaths',
      headers: await _getAuthHeaders(),
    );
    _throwIfError(response, 'GET /learningpaths');
    final paths = (response.data as List?) ?? [];
    return paths.map((e) => LearningPathApiModel.fromJson(e)).toList();
  }

  Future<LearningPathApiModel> getLearningPathById(String pathId) async {
    final response = await _apiHandler.get(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/$pathId',
      headers: await _getAuthHeaders(),
    );
    _throwIfError(response, 'GET /learningpaths/$pathId');
    return LearningPathApiModel.fromJson(response.data);
  }

  Future<List<LearningPathApiModel>> getRecommendedLearningPaths() async {
    final response = await _apiHandler.get(
      url: '${ApiConfig.apiBackendUrl}/home/recommendation',
      headers: await _getAuthHeaders(),
    );
    _throwIfError(response, 'GET /home/recommendation');

    final raw = response.data;
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((e) => LearningPathApiModel.fromJson(e)).toList();
    }
    if (raw is Map<String, dynamic>) {
      final popular = raw['popular'];
      if (popular is List) {
        return popular.map((e) => LearningPathApiModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<LearningPathProgressApiModel> getLearningPathProgress(
    String pathId,
  ) async {
    final userId = await _getUserIdFromToken();
    final response = await _apiHandler.get(
      url: '${ApiConfig.apiBackendUrl}/user/learningpaths/$pathId/progress?user_id=$userId',
      headers: await _getAuthHeaders(),
    );
    _throwIfError(response, 'GET progress/$pathId');
    return LearningPathProgressApiModel.fromJson(response.data);
  }

  Future<List<EnrolledLearningPathApiModel>> getEnrolledPaths(
    String userId,
  ) async {
    final response = await _apiHandler.get(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/user/enroll',
      headers: await _getAuthHeaders(),
    );
    _throwIfError(response, 'GET enrolled paths');
    final list = (response.data as List?) ?? [];
    return list.map((e) => EnrolledLearningPathApiModel.fromJson(e)).toList();
  }

  Future<String> createLearningPath(CreatePathRequestApiModel request) async {
    final response = await _apiHandler.post(
      url: '${ApiConfig.apiBackendUrl}/learningpaths',
      headers: await _getAuthHeaders(),
      body: request.toJson(),
    );
    _throwIfError(response, 'POST /learningpaths');
    final pathId = (response.data as Map<String, dynamic>?)?['path_id'] as String?;
    if (pathId == null || pathId.isEmpty) {
      throw ServerException(message: 'Path ID not returned from server');
    }
    return pathId;
  }

  Future<void> enrollPath(String pathId, String userId) async {
    final response = await _apiHandler.post(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/$pathId/start',
      headers: await _getAuthHeaders(),
      body: {'user_id': userId},
    );
    _throwIfError(response, 'POST enroll/$pathId');
  }

  Future<void> updateLearningPath(
    String pathId,
    String title,
    String objective,
    String description,
    String? coverImgUrl,
    String publishStatus,
  ) async {
    final Map<String, dynamic> body = {
      'title': title,
      'objective': objective,
      'description': description,
      'publish_status': publishStatus,
    };
    if (coverImgUrl != null && coverImgUrl.isNotEmpty) {
      body['cover_img_url'] = coverImgUrl;
    }

    final response = await _apiHandler.put(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/$pathId',
      headers: await _getAuthHeaders(),
      body: body,
    );
    _throwIfError(response, 'PUT /learningpaths/$pathId');
  }

  Future<void> deleteLearningPath(String pathId) async {
    final response = await _apiHandler.delete(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/$pathId',
      headers: await _getAuthHeaders(),
    );
    _throwIfError(response, 'DELETE /learningpaths/$pathId');
  }

  // ── Nodes ─────────────────────────────────────────────────────────────────

  Future<List<LearningNodeApiModel>> getNodesForPath(String pathId) async {
    final response = await _apiHandler.get(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/$pathId/nodes',
      headers: await _getAuthHeaders(),
    );
    _throwIfError(response, 'GET nodes/$pathId');
    final nodes = (response.data as List?) ?? [];
    return nodes.map((e) => LearningNodeApiModel.fromJson(e)).toList();
  }

  Future<NodeDetailApiModel> getNodeDetail(String nodeId) async {
    final response = await _apiHandler.get(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId',
      headers: await _getAuthHeaders(),
    );
    _throwIfError(response, 'GET node/$nodeId');
    return NodeDetailApiModel.fromJson(response.data);
  }

  Future<String> createNode(CreateNodeRequestApiModel request) async {
    final response = await _apiHandler.post(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/${request.pathId}/nodes',
      headers: await _getAuthHeaders(),
      body: request.toJson(),
    );
    _throwIfError(response, 'POST nodes/${request.pathId}');
    final nodeId = (response.data as Map<String, dynamic>?)?['node_id'] as String?;
    if (nodeId == null || nodeId.isEmpty) {
      throw ServerException(message: 'Node ID not returned from server');
    }
    return nodeId;
  }

  Future<void> startNode(String nodeId) async {
    final response = await _apiHandler.put(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/start',
      headers: await _getAuthHeaders(),
    );
    _throwIfError(response, 'PUT node/start/$nodeId');
  }

  Future<void> completeNode(String nodeId) async {
    final response = await _apiHandler.put(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/complete',
      headers: await _getAuthHeaders(),
    );
    _throwIfError(response, 'PUT node/complete/$nodeId');
  }

  Future<void> updateNode(
    String nodeId,
    String title,
    String description, {
    String? linkvdo,
    List<CreateMaterial>? materials,
  }) async {
    final Map<String, dynamic> body = {
      'title': title,
      'description': description,
    };
    if (linkvdo != null && linkvdo.isNotEmpty) {
      body['link_vdo'] = linkvdo;
    }
    if (materials != null && materials.isNotEmpty) {
      body['material'] = materials
          .map((m) => CreateMaterialRequestApiModel(type: m.type, url: m.url).toJson())
          .toList();
    }

    final response = await _apiHandler.put(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId',
      headers: await _getAuthHeaders(),
      body: body,
    );
    _throwIfError(response, 'PUT node/$nodeId');
  }

  Future<void> deleteNode(String nodeId) async {
    final response = await _apiHandler.delete(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId',
      headers: await _getAuthHeaders(),
    );
    _throwIfError(response, 'DELETE node/$nodeId');
  }

  // ── Questions ─────────────────────────────────────────────────────────────

  Future<List<QuizQuestionApiModel>> getNodeQuestions(String nodeId) async {
    final response = await _apiHandler.get(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/questions',
      headers: await _getAuthHeaders(),
    );
    _throwIfError(response, 'GET questions/$nodeId');
    final questions = (response.data as List?) ?? [];
    return questions.map((e) => QuizQuestionApiModel.fromJson(e)).toList();
  }

  Future<void> createNodeQuestions(
    String nodeId,
    List<CreateQuestionWithChoicesRequestApiModel> questions,
  ) async {
    if (questions.isEmpty) return;

    // Try batch endpoint first
    try {
      final response = await _apiHandler.post(
        url: '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/questions/batch',
        headers: await _getAuthHeaders(),
        body: {
          'questions': questions.map((q) => {
            'question_text': q.questionText,
            'type': q.type,
            'choices': q.choices.map((c) => {
              'choice_text': c.choiceText,
              'is_correct': c.isCorrect,
              'reasoning': c.reasoning,
            }).toList(),
          }).toList(),
        },
      );
      if (response.isSuccess) {
        LogHandler.info('Created ${questions.length} questions using batch endpoint');
        return;
      }
      LogHandler.warning('Batch endpoint failed (${response.statusCode}), falling back to parallel creation');
    } catch (e) {
      LogHandler.warning('Batch endpoint threw: $e, falling back to parallel creation');
    }

    // Fallback: parallel creation
    try {
      final futures = questions.map((question) async {
        final qResponse = await _apiHandler.post(
          url: '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/questions',
          headers: await _getAuthHeaders(),
          body: {'question_text': question.questionText, 'type': question.type},
        );
        _throwIfError(qResponse, 'POST question/$nodeId');

        final questionId = (qResponse.data as Map<String, dynamic>?)?['question_id'] as String?;
        if (questionId == null || questionId.isEmpty) {
          throw ServerException(message: 'Question ID not returned from server');
        }

        final choiceFutures = question.choices.map((choice) async {
          final cResponse = await _apiHandler.post(
            url: '${ApiConfig.apiBackendUrl}/learningpaths/questions/$questionId/choices',
            headers: await _getAuthHeaders(),
            body: {
              'choice_text': choice.choiceText,
              'is_correct': choice.isCorrect,
              'reasoning': choice.reasoning,
            },
          );
          _throwIfError(cResponse, 'POST choice/$questionId');
        });
        await Future.wait(choiceFutures);
      });

      await Future.wait(futures);
      LogHandler.info('Created ${questions.length} questions using parallel fallback');
    } catch (e) {
      LogHandler.error('Exception in createNodeQuestions: $e');
      throw ServerException(message: 'Failed to create node questions: $e');
    }
  }

  // ── AI ────────────────────────────────────────────────────────────────────

  Future<AIGenerateResponseApiModel> generateNodesWithAI(String topic) async {
    final response = await _apiHandler.post(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/generate',
      headers: await _getAuthHeaders(),
      body: {'topic': topic},
    );
    _throwIfError(response, 'POST /learningpaths/generate');
    return AIGenerateResponseApiModel.fromJson(response.data);
  }
}
