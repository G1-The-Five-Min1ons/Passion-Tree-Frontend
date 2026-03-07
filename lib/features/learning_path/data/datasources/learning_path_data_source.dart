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
import 'package:passion_tree_frontend/features/learning_path/data/models/ai_generate_response_api_model.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_material.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_material_request_api_model.dart';

class LearningPathDataSource {
  final http.Client client;

  LearningPathDataSource({http.Client? client})
    : client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await getIt<AuthLocalDataSource>().getToken();
      if (token != null && token.isNotEmpty) {
        return ApiConfig.getAuthHeaders(token);
      }
    } catch (_) {}
    return ApiConfig.defaultHeaders;
  }

  Future<List<LearningPathApiModel>> getAllLearningPaths() async {
    try {
      LogHandler.debug('[DataSource] GET /learningpaths');

      final response = await client.get(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths'),
        headers: await _getHeaders(),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final paths = data['data'] as List?;

          if (paths == null || paths.isEmpty) {
            return [];
          }

          return paths
              .map((path) => LearningPathApiModel.fromJson(path))
              .toList();
        } on FormatException catch (e) {
          LogHandler.error('Failed to parse JSON response: $e');
          throw Exception(
            'Server returned invalid JSON response (possibly HTML error page)',
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.error('Failed to get learning paths: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get learning paths');
        } on FormatException {
          LogHandler.error(
            'Failed to get learning paths (Status ${response.statusCode})',
          );
          throw Exception(
            'Failed to get learning paths (Status ${response.statusCode})',
          );
        }
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
      LogHandler.error('Exception in getAllLearningPaths: $e');
      throw Exception('Failed to fetch learning paths: $e');
    }
  }

  Future<LearningPathProgressApiModel> getLearningPathProgress(
    String pathId,
    String userId,
  ) async {
    try {
      LogHandler.debug('[DataSource] GET /user/learningpaths/$pathId/progress');

      final response = await client.get(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/user/learningpaths/$pathId/progress?user_id=$userId',
        ),
        headers: await _getHeaders(),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return LearningPathProgressApiModel.fromJson(data['data']);
        } on FormatException catch (e) {
          LogHandler.error('Failed to parse progress JSON: $e');
          throw Exception(
            'Server returned invalid JSON response (possibly HTML error page)',
          );
        }
      } else {
        LogHandler.error(
          'Failed to load progress (Status ${response.statusCode})',
        );
        throw Exception('Failed to load progress');
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
      LogHandler.error('Exception in getLearningPathProgress: $e');
      rethrow;
    }
  }

  Future<List<EnrolledLearningPathApiModel>> getEnrolledPaths(
    String userId,
  ) async {
    try {
      LogHandler.debug('[DataSource] GET /learningpaths/user/enroll');

      final response = await client.get(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/user/enroll',
        ),
        headers: await _getHeaders(),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final list = data['data'] as List?;

          if (list == null || list.isEmpty) {
            return [];
          }

          return list
              .map((e) => EnrolledLearningPathApiModel.fromJson(e))
              .toList();
        } on FormatException catch (e) {
          LogHandler.error('Failed to parse enrolled paths JSON: $e');
          throw Exception(
            'Server returned invalid JSON response (possibly HTML error page)',
          );
        }
      } else {
        LogHandler.error(
          'Failed to load enrolled paths (Status ${response.statusCode})',
        );
        throw Exception('Failed to load enrolled paths: ${response.body}');
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
      LogHandler.error('Exception in getEnrolledPaths: $e');
      rethrow;
    }
  }

  Future<List<LearningNodeApiModel>> getNodesForPath(
    String pathId,
    String userId,
  ) async {
    try {
      LogHandler.debug('[DataSource] GET /learningpaths/$pathId/nodes');

      final response = await client.get(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/$pathId/nodes?user_id=$userId',
        ),
        headers: await _getHeaders(),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final nodes = data['data'] as List?;

          if (nodes == null || nodes.isEmpty) {
            return [];
          }

          return nodes
              .map((node) => LearningNodeApiModel.fromJson(node))
              .toList();
        } on FormatException catch (e) {
          LogHandler.error('Failed to parse nodes JSON: $e');
          throw Exception(
            'Server returned invalid JSON response (possibly HTML error page)',
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.error('Failed to get nodes: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get nodes');
        } on FormatException {
          LogHandler.error(
            'Failed to get nodes (Status ${response.statusCode})',
          );
          throw Exception(
            'Failed to get nodes (Status ${response.statusCode})',
          );
        }
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
      LogHandler.error('Exception in getNodesForPath: $e');
      throw Exception('Failed to fetch nodes: $e');
    }
  }

  Future<NodeDetailApiModel> getNodeDetail(String nodeId, String userId) async {
    try {
      LogHandler.debug('[DataSource] GET /learningpaths/nodes/$nodeId');

      final response = await client.get(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId?user_id=$userId',
        ),
        headers: await _getHeaders(),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return NodeDetailApiModel.fromJson(data['data']);
        } on FormatException catch (e) {
          LogHandler.error('Failed to parse node detail JSON: $e');
          throw Exception(
            'Server returned invalid JSON response (possibly HTML error page)',
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.error('Failed to get node detail: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get node detail');
        } on FormatException {
          LogHandler.error(
            'Failed to get node detail (Status ${response.statusCode})',
          );
          throw Exception(
            'Failed to get node detail (Status ${response.statusCode})',
          );
        }
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
      LogHandler.error('Exception in getNodeDetail: $e');
      throw Exception('Failed to fetch node detail: $e');
    }
  }

  Future<List<QuizQuestionApiModel>> getNodeQuestions(String nodeId) async {
    try {
      LogHandler.debug(
        '[DataSource] GET /learningpaths/nodes/$nodeId/questions',
      );

      final response = await client.get(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/questions',
        ),
        headers: await _getHeaders(),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final questions = data['data'] as List?;

          if (questions == null || questions.isEmpty) {
            return [];
          }

          return questions
              .map((question) => QuizQuestionApiModel.fromJson(question))
              .toList();
        } on FormatException catch (e) {
          LogHandler.error('Failed to parse questions JSON: $e');
          throw Exception(
            'Server returned invalid JSON response (possibly HTML error page)',
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.error('Failed to get questions: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get questions');
        } on FormatException {
          LogHandler.error(
            'Failed to get questions (Status ${response.statusCode})',
          );
          throw Exception(
            'Failed to get questions (Status ${response.statusCode})',
          );
        }
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
      LogHandler.error('Exception in getNodeQuestions: $e');
      throw Exception('Failed to fetch questions: $e');
    }
  }

  Future<void> startNode(String nodeId, String userId) async {
    try {
      LogHandler.debug('[DataSource] PUT /learningpaths/nodes/$nodeId/start');

      final response = await client.put(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/start?user_id=$userId',
        ),
        headers: await _getHeaders(),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          final msg = error['error'] ?? error['message'] ?? 'Failed to start node (${response.statusCode})';
          LogHandler.error('Failed to start node: $msg (Status ${response.statusCode}): ${response.body}');
          throw Exception(msg);
        } on FormatException {
          LogHandler.error(
            'Failed to start node (Status ${response.statusCode}): ${response.body}',
          );
          throw Exception(
            'Failed to start node (Status ${response.statusCode})',
          );
        }
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
      LogHandler.error('Exception in startNode: $e');
      throw Exception('Failed to start node: $e');
    }
  }

  Future<void> completeNode(String nodeId, String userId) async {
    try {
      LogHandler.debug(
        '[DataSource] PUT /learningpaths/nodes/$nodeId/complete',
      );

      final response = await client.put(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/complete',
        ),
        headers: await _getHeaders(),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          final msg = error['error'] ?? error['message'] ?? 'Failed to complete node (${response.statusCode})';
          LogHandler.error('Failed to complete node: $msg (Status ${response.statusCode}): ${response.body}');
          throw Exception(msg);
        } on FormatException {
          LogHandler.error(
            'Failed to complete node (Status ${response.statusCode}): ${response.body}',
          );
          throw Exception(
            'Failed to complete node (Status ${response.statusCode})',
          );
        }
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
      LogHandler.error('Exception in completeNode: $e');
      throw Exception('Failed to complete node: $e');
    }
  }

  Future<void> enrollPath(String pathId, String userId) async {
    try {
      LogHandler.debug('[DataSource] POST /learningpaths/$pathId/start');

      final response = await client.post(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/$pathId/start'),
        headers: await _getHeaders(),
        body: jsonEncode({'user_id': userId}),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.error('[DataSource] Enroll failed: ${error['message']}');
          throw Exception(
            error['message'] ?? 'Failed to enroll in learning path',
          );
        } catch (e) {
          LogHandler.error(
            '[DataSource] Enroll failed (Status ${response.statusCode})',
          );
          throw Exception(
            'Failed to enroll (Status ${response.statusCode}): ${response.body}',
          );
        }
      }
    } on SocketException catch (e) {
      LogHandler.error('[DataSource] No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.error('[DataSource] Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.error('[DataSource] HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.error('[DataSource] Exception in enrollPath: $e');
      rethrow;
    }
  }

  Future<void> deleteLearningPath(String pathId) async {
    try {
      LogHandler.debug('[DataSource] DELETE /learningpaths/$pathId');

      final response = await client.delete(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/$pathId'),
        headers: await _getHeaders(),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.error(
            'Failed to delete learning path: ${error['message']}',
          );
          throw Exception(error['message'] ?? 'Failed to delete learning path');
        } on FormatException {
          LogHandler.error(
            'Failed to delete learning path (Status ${response.statusCode})',
          );
          throw Exception(
            'Failed to delete learning path (Status ${response.statusCode})',
          );
        }
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
      LogHandler.error('Exception in deleteLearningPath: $e');
      throw Exception('Failed to delete learning path: $e');
    }
  }

  // TEACHER FEATURES

  Future<String> createLearningPath(CreatePathRequestApiModel request) async {
    try {
      LogHandler.debug('[DataSource] POST /learningpaths');

      final response = await client.post(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths'),
        headers: await _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          final pathId = data['data']['path_id'] as String?;
          if (pathId == null || pathId.isEmpty) {
            throw Exception('Path ID not returned from server');
          }
          return pathId;
        } on FormatException catch (e) {
          LogHandler.error('Failed to parse JSON response: $e');
          throw Exception(
            'Server returned invalid JSON response (possibly HTML error page)',
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.error(
            'Failed to create learning path: ${error['message']}',
          );
          throw Exception(
            error['message'] ?? 'Failed to create learning path',
          );
        } on FormatException {
          LogHandler.error(
            'Failed to create learning path (Status ${response.statusCode})',
          );
          throw Exception(
            'Failed to create learning path (Status ${response.statusCode})',
          );
        }
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
      LogHandler.error('Exception in createLearningPath: $e');
      throw Exception('Failed to create learning path: $e');
    }
  }

  Future<String> createNode(CreateNodeRequestApiModel request) async {
    try {
      LogHandler.debug(
        '[DataSource] POST /learningpaths/${request.pathId}/nodes',
      );

      final response = await client.post(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/${request.pathId}/nodes',
        ),
        headers: await _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          final nodeId = data['data']['node_id'] as String?;
          if (nodeId == null || nodeId.isEmpty) {
            throw Exception('Node ID not returned from server');
          }
          return nodeId;
        } on FormatException catch (e) {
          LogHandler.error('Failed to parse JSON response: $e');
          throw Exception(
            'Server returned invalid JSON response (possibly HTML error page)',
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.error('Failed to create node: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to create node');
        } on FormatException {
          LogHandler.error(
            'Failed to create node (Status ${response.statusCode})',
          );
          throw Exception(
            'Failed to create node (Status ${response.statusCode})',
          );
        }
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
      LogHandler.error('Exception in createNode: $e');
      throw Exception('Failed to create node: $e');
    }
  }

  Future<AIGenerateResponseApiModel> generateNodesWithAI(String topic) async {
    try {
      LogHandler.debug('[DataSource] POST /learningpaths/generate');

      final response = await client.post(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/generate'),
        headers: await _getHeaders(),
        body: jsonEncode({'topic': topic}),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          return AIGenerateResponseApiModel.fromJson(data['data']);
        } on FormatException catch (e) {
          LogHandler.error('Failed to parse JSON response: $e');
          throw Exception(
            'Server returned invalid JSON response (possibly HTML error page)',
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.error('Failed to generate nodes: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to generate nodes');
        } on FormatException {
          LogHandler.error(
            'Failed to generate nodes (Status ${response.statusCode})',
          );
          throw Exception(
            'Failed to generate nodes (Status ${response.statusCode})',
          );
        }
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
      LogHandler.error('Exception in generateNodesWithAI: $e');
      throw Exception('Failed to generate nodes with AI: $e');
    }
  }

  Future<LearningPathApiModel> getLearningPathById(String pathId) async {
    try {
      LogHandler.debug('[DataSource] GET /learningpaths/$pathId');

      final response = await client.get(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/$pathId'),
        headers: await _getHeaders(),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return LearningPathApiModel.fromJson(data['data']);
        } on FormatException catch (e) {
          LogHandler.error('Failed to parse JSON response: $e');
          throw Exception(
            'Server returned invalid JSON response (possibly HTML error page)',
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.error('Failed to get learning path: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get learning path');
        } on FormatException {
          LogHandler.error(
            'Failed to get learning path (Status ${response.statusCode})',
          );
          throw Exception(
            'Failed to get learning path (Status ${response.statusCode})',
          );
        }
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
      LogHandler.error('Exception in getLearningPathById: $e');
      throw Exception('Failed to get learning path: $e');
    }
  }

  Future<void> updateNode(
    String nodeId,
    String title,
    String description, {
    String? linkvdo,
    List<CreateMaterial>? materials,
  }) async {
    try {
      LogHandler.debug('[DataSource] PUT /learningpaths/nodes/$nodeId');

      final Map<String, dynamic> body = {
        'title': title,
        'description': description,
      };

      // เพิ่ม linkvdo ถ้ามี
      if (linkvdo != null && linkvdo.isNotEmpty) {
        body['link_vdo'] = linkvdo;
      }

      // เพิ่ม materials ถ้ามี
      if (materials != null && materials.isNotEmpty) {
        body['material'] = materials
            .map((m) => CreateMaterialRequestApiModel(
                  type: m.type,
                  url: m.url,
                ).toJson())
            .toList();
      }

      final response = await client.put(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.error('Failed to update node: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to update node');
        } on FormatException {
          LogHandler.error(
            'Failed to update node (Status ${response.statusCode})',
          );
          throw Exception(
            'Failed to update node (Status ${response.statusCode})',
          );
        }
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
      LogHandler.error('Exception in updateNode: $e');
      throw Exception('Failed to update node: $e');
    }
  }
}
