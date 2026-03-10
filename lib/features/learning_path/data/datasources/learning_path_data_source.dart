import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_path_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_path_progress_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/enrolled_learning_path_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_node_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/node_detail_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/quiz_question_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_path_request_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_node_request_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_choice_request_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_question_with_choices_request_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/ai_generate_response_api_model.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_material.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_material_request_api_model.dart';

class LearningPathDataSource {
  final http.Client client;

  LearningPathDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Get headers with token, checking for expiry
  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await getIt<AuthLocalDataSource>().getToken();
      if (token != null && token.isNotEmpty) {
        // Check if token is expired
        if (_isTokenExpired(token)) {
          LogHandler.warning('[DataSource] Token is expired');
          // Clear expired token
          await getIt<AuthLocalDataSource>().clearAuth();
          return ApiConfig.defaultHeaders;
        }
        return ApiConfig.getAuthHeaders(token);
      }
    } catch (e) {
      LogHandler.error('[DataSource] Error getting headers: $e');
    }
    return ApiConfig.defaultHeaders;
  }

  /// Check if JWT token is expired
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode payload (second part)
      final payload = parts[1];
      // Add padding if needed
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final Map<String, dynamic> payloadMap = jsonDecode(decoded);

      // Check expiration
      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        final now = DateTime.now();
        // Add 1 minute buffer
        return now.isAfter(expiryDate.subtract(const Duration(minutes: 1)));
      }
      return false;
    } catch (e) {
      LogHandler.error('[DataSource] Error checking token expiry: $e');
      return true; // Consider invalid tokens as expired
    }
  }

  /// Generic GET request handler
  Future<T> _makeGetRequest<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    String? errorMessage,
  }) async {
    try {
      LogHandler.debug('[DataSource] GET $endpoint');

      final response = await client.get(
        Uri.parse('${ApiConfig.apiBackendUrl}$endpoint'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        final error = _parseError(response);
        throw Exception(error ?? errorMessage ?? 'Request failed');
      }
    } on SocketException catch (e) {
      LogHandler.error('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.error('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.error('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.error('Exception in GET $endpoint: $e');
      rethrow;
    }
  }

  /// Generic POST request handler
  Future<T> _makePostRequest<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>) fromJson,
    String? errorMessage,
  }) async {
    try {
      LogHandler.debug('[DataSource] POST $endpoint');

      final response = await client.post(
        Uri.parse('${ApiConfig.apiBackendUrl}$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        final error = _parseError(response);
        throw Exception(error ?? errorMessage ?? 'Request failed');
      }
    } on SocketException catch (e) {
      LogHandler.error('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.error('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.error('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.error('Exception in POST $endpoint: $e');
      rethrow;
    }
  }

  /// Generic PUT request handler
  Future<void> _makePutRequest({
    required String endpoint,
    Map<String, dynamic>? body,
    String? errorMessage,
  }) async {
    try {
      LogHandler.debug('[DataSource] PUT $endpoint');

      final response = await client.put(
        Uri.parse('${ApiConfig.apiBackendUrl}$endpoint'),
        headers: await _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else {
        final error = _parseError(response);
        throw Exception(error ?? errorMessage ?? 'Request failed');
      }
    } on SocketException catch (e) {
      LogHandler.error('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.error('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.error('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.error('Exception in PUT $endpoint: $e');
      rethrow;
    }
  }

  /// Generic DELETE request handler
  Future<void> _makeDeleteRequest({
    required String endpoint,
    String? errorMessage,
  }) async {
    try {
      LogHandler.debug('[DataSource] DELETE $endpoint');

      final response = await client.delete(
        Uri.parse('${ApiConfig.apiBackendUrl}$endpoint'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else {
        final error = _parseError(response);
        throw Exception(error ?? errorMessage ?? 'Request failed');
      }
    } on SocketException catch (e) {
      LogHandler.error('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.error('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.error('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.error('Exception in DELETE $endpoint: $e');
      rethrow;
    }
  }

  /// Parse error from response
  String? _parseError(http.Response response) {
    try {
      final error = jsonDecode(response.body);
      return error['message'] ?? error['error'];
    } on FormatException {
      return 'Request failed (Status ${response.statusCode})';
    }
  }

  Future<List<LearningPathApiModel>> getAllLearningPaths() async {
    return await _makeGetRequest(
      endpoint: '/learningpaths',
      fromJson: (data) {
        final paths = data['data'] as List?;
        if (paths == null || paths.isEmpty) return [];
        return paths.map((path) => LearningPathApiModel.fromJson(path)).toList();
      },
      errorMessage: 'Failed to get learning paths',
    );
  }

  Future<LearningPathProgressApiModel> getLearningPathProgress(
    String pathId,
    String userId,
  ) async {
    return await _makeGetRequest(
      endpoint: '/user/learningpaths/$pathId/progress?user_id=$userId',
      fromJson: (data) => LearningPathProgressApiModel.fromJson(data['data']),
      errorMessage: 'Failed to load progress',
    );
  }

  Future<List<EnrolledLearningPathApiModel>> getEnrolledPaths(
    String userId,
  ) async {
    return await _makeGetRequest(
      endpoint: '/learningpaths/user/enroll',
      fromJson: (data) {
        final list = data['data'] as List?;
        if (list == null || list.isEmpty) return [];
        return list.map((e) => EnrolledLearningPathApiModel.fromJson(e)).toList();
      },
      errorMessage: 'Failed to load enrolled paths',
    );
  }

  Future<List<LearningNodeApiModel>> getNodesForPath(
    String pathId,
    String _userId,
  ) async {
    return await _makeGetRequest(
      endpoint: '/learningpaths/$pathId/nodes',
      fromJson: (data) {
        final nodes = data['data'] as List?;
        if (nodes == null || nodes.isEmpty) return [];
        return nodes.map((node) => LearningNodeApiModel.fromJson(node)).toList();
      },
      errorMessage: 'Failed to load nodes',
    );
  }

  Future<NodeDetailApiModel> getNodeDetail(String nodeId, String _userId) async {
    return await _makeGetRequest(
      endpoint: '/learningpaths/nodes/$nodeId',
      fromJson: (data) => NodeDetailApiModel.fromJson(data['data']),
      errorMessage: 'Failed to load node detail',
    );
  }

  Future<List<QuizQuestionApiModel>> getNodeQuestions(String nodeId) async {
    return await _makeGetRequest(
      endpoint: '/learningpaths/nodes/$nodeId/questions',
      fromJson: (data) {
        final questions = data['data'] as List?;
        if (questions == null || questions.isEmpty) return [];
        return questions.map((q) => QuizQuestionApiModel.fromJson(q)).toList();
      },
      errorMessage: 'Failed to load questions',
    );
  }

  Future<void> createNodeQuestions(
    String nodeId,
    List<CreateQuestionWithChoicesRequestApiModel> questions,
  ) async {
    if (questions.isEmpty) return;

    // Try batch endpoint first to solve N+1 problem
    try {
      LogHandler.debug(
        '[DataSource] POST /learningpaths/nodes/$nodeId/questions/batch (N=${questions.length})',
      );

      await _makePostRequest(
        endpoint: '/learningpaths/nodes/$nodeId/questions/batch',
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
        fromJson: (_) => null,
        errorMessage: 'Failed to create questions in batch',
      );
      
      LogHandler.info('Successfully created ${questions.length} questions using batch endpoint');
      return;
    } catch (e) {
      LogHandler.warning('Batch endpoint failed: $e, falling back to parallel creation');
    }

    // Fallback: parallel execution to reduce time (N+N*M calls, but in parallel)
    try {
      final futures = questions.map((question) async {
        // Create question
        final questionId = await _makePostRequest<String>(
          endpoint: '/learningpaths/nodes/$nodeId/questions',
          body: {
            'question_text': question.questionText,
            'type': question.type,
          },
          fromJson: (data) {
            final id = data['data']?['question_id'] as String?;
            if (id == null || id.isEmpty) {
              throw Exception('Question ID not returned from server');
            }
            return id;
          },
          errorMessage: 'Failed to create question',
        );

        // Create all choices for this question in parallel
        final choiceFutures = question.choices.map((choice) async {
          await _makePostRequest(
            endpoint: '/learningpaths/questions/$questionId/choices',
            body: {
              'choice_text': choice.choiceText,
              'is_correct': choice.isCorrect,
              'reasoning': choice.reasoning,
            },
            fromJson: (_) => null,
            errorMessage: 'Failed to create choice',
          );
        });

        await Future.wait(choiceFutures);
      });

      await Future.wait(futures);
      LogHandler.info('Created ${questions.length} questions using parallel fallback');
    } catch (e) {
      LogHandler.error('Exception in createNodeQuestions: $e');
      throw Exception('Failed to create node questions: $e');
    }
  }

  Future<void> startNode(String nodeId, String _userId) async {
    await _makePutRequest(
      endpoint: '/learningpaths/nodes/$nodeId/start',
      errorMessage: 'Failed to start node',
    );
  }

  Future<void> completeNode(String nodeId, String _userId) async {
    await _makePutRequest(
      endpoint: '/learningpaths/nodes/$nodeId/complete',
      errorMessage: 'Failed to complete node',
    );
  }

  Future<void> enrollPath(String pathId, String userId) async {
    await _makePostRequest(
      endpoint: '/learningpaths/$pathId/start',
      body: {'user_id': userId},
      fromJson: (_) => null,
      errorMessage: 'Failed to enroll in learning path',
    );
  }

  Future<void> deleteLearningPath(String pathId) async {
    await _makeDeleteRequest(
      endpoint: '/learningpaths/$pathId',
      errorMessage: 'Failed to delete learning path',
    );
  }

  Future<void> deleteNode(String nodeId) async {
    await _makeDeleteRequest(
      endpoint: '/learningpaths/nodes/$nodeId',
      errorMessage: 'Failed to delete node',
    );
  }

  // TEACHER FEATURES

  Future<String> createLearningPath(CreatePathRequestApiModel request) async {
    return await _makePostRequest(
      endpoint: '/learningpaths',
      body: request.toJson(),
      fromJson: (data) {
        final pathId = data['data']['path_id'] as String?;
        if (pathId == null || pathId.isEmpty) {
          throw Exception('Path ID not returned from server');
        }
        return pathId;
      },
      errorMessage: 'Failed to create learning path',
    );
  }

  Future<String> createNode(CreateNodeRequestApiModel request) async {
    return await _makePostRequest(
      endpoint: '/learningpaths/${request.pathId}/nodes',
      body: request.toJson(),
      fromJson: (data) {
        final nodeId = data['data']['node_id'] as String?;
        if (nodeId == null || nodeId.isEmpty) {
          throw Exception('Node ID not returned from server');
        }
        return nodeId;
      },
      errorMessage: 'Failed to create node',
    );
  }

  Future<AIGenerateResponseApiModel> generateNodesWithAI(String topic) async {
    return await _makePostRequest(
      endpoint: '/learningpaths/generate',
      body: {'topic': topic},
      fromJson: (data) => AIGenerateResponseApiModel.fromJson(data['data']),
      errorMessage: 'Failed to generate nodes with AI',
    );
  }

  Future<LearningPathApiModel> getLearningPathById(String pathId) async {
    return await _makeGetRequest(
      endpoint: '/learningpaths/$pathId',
      fromJson: (data) => LearningPathApiModel.fromJson(data['data']),
      errorMessage: 'Failed to get learning path',
    );
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
          .map((m) => CreateMaterialRequestApiModel(
                type: m.type,
                url: m.url,
              ).toJson())
          .toList();
    }

    await _makePutRequest(
      endpoint: '/learningpaths/nodes/$nodeId',
      body: body,
      errorMessage: 'Failed to update node',
    );
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

    await _makePutRequest(
      endpoint: '/learningpaths/$pathId',
      body: body,
      errorMessage: 'Failed to update learning path',
    );
  }
}
