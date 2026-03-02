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
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

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
      LogHandler.info('[DataSource] Fetching all learning paths...');
      LogHandler.info('API: ${ApiConfig.apiBackendUrl}/learningpaths');
      
      final response = await client.get(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths'),
        headers: await _getHeaders(),
      );

      LogHandler.info('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final paths = data['data'] as List?;
        
        if (paths == null || paths.isEmpty) {
          LogHandler.info('No learning paths found (empty or null)');
          return [];
        }
        
        LogHandler.info('Successfully fetched ${paths.length} learning paths');
        
        return paths
            .map((path) => LearningPathApiModel.fromJson(path))
            .toList();
        } on FormatException catch (e) {
          LogHandler.info('Failed to parse JSON response: $e');
          LogHandler.info('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response (possibly HTML error page)');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.info('Failed to get learning paths: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get learning paths');
        } on FormatException {
          LogHandler.info('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to get learning paths (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      LogHandler.info('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.info('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.info('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.info('Exception in getAllLearningPaths: $e');
      throw Exception('Failed to fetch learning paths: $e');
    }
  }
  Future<LearningPathProgressApiModel> getLearningPathProgress(
    String pathId,
    String userId,
  ) async {
    try {
      LogHandler.info('[DataSource] Fetching learning path progress...');
      LogHandler.info('API: /user/learningpaths/$pathId/progress');
      LogHandler.info('User ID: $userId');
      
      final response = await client.get(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/user/learningpaths/$pathId/progress?user_id=$userId',
        ),
        headers: await _getHeaders(),
      );

      LogHandler.info('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          LogHandler.info('Successfully fetched progress for path: $pathId');
          return LearningPathProgressApiModel.fromJson(data['data']);
        } on FormatException catch (e) {
          LogHandler.info('Failed to parse JSON response: $e');
          LogHandler.info('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response (possibly HTML error page)');
        }
      } else {
        LogHandler.info('Failed to load progress');
        throw Exception('Failed to load progress');
      }
    } on SocketException catch (e) {
      LogHandler.info('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.info('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.info('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.info('Exception in getLearningPathProgress: $e');
      rethrow;
    }
  }
  Future<List<EnrolledLearningPathApiModel>> getEnrolledPaths(
    String userId,
  ) async {
    try {
      LogHandler.info('[DataSource] Fetching enrolled paths...');
      LogHandler.info('API: /user/learningpaths/history');
      LogHandler.info('User ID: $userId');
      
      final response = await client.get(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/user/learningpaths/history?user_id=$userId',
        ),
        headers: await _getHeaders(),
      );

      LogHandler.info('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final list = data['data'] as List?;
          
          if (list == null || list.isEmpty) {
            LogHandler.info('No enrolled paths found (empty or null)');
            return [];
          }
          
          LogHandler.info('Successfully fetched ${list.length} enrolled paths');
          
          return list.map((e) => EnrolledLearningPathApiModel.fromJson(e)).toList();
        } on FormatException catch (e) {
          LogHandler.info('Failed to parse JSON response: $e');
          LogHandler.info('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response (possibly HTML error page)');
        }
      } else {
        LogHandler.info('Failed to load enrolled paths. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load enrolled paths: ${response.body}');
      }
    } on SocketException catch (e) {
      LogHandler.info('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.info('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.info('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.info('Exception in getEnrolledPaths: $e');
      rethrow;
    }
  }

  Future<List<LearningNodeApiModel>> getNodesForPath(String pathId, String userId) async {
    try {
      LogHandler.info('[DataSource] Fetching nodes for path...');
      LogHandler.info('API: /learningpaths/$pathId/nodes');
      LogHandler.info('User ID: $userId');
      
      final response = await client.get(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/$pathId/nodes?user_id=$userId'),
        headers: await _getHeaders(),
      );

      LogHandler.info('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final nodes = data['data'] as List?;
        
        if (nodes == null || nodes.isEmpty) {
          LogHandler.info('No nodes found for path: $pathId (empty or null)');
          return [];
        }
        
        LogHandler.info('Successfully fetched ${nodes.length} nodes for path: $pathId');

        return nodes
            .map((node) => LearningNodeApiModel.fromJson(node))
            .toList();
        } on FormatException catch (e) {
          LogHandler.info('Failed to parse JSON response: $e');
          LogHandler.info('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response (possibly HTML error page)');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.info('Failed to get nodes: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get nodes');
        } on FormatException {
          LogHandler.info('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to get nodes (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      LogHandler.info('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.info('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.info('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.info('Exception in getNodesForPath: $e');
      throw Exception('Failed to fetch nodes: $e');
    }
  }

  Future<NodeDetailApiModel> getNodeDetail(String nodeId, String userId) async {
    try {
      LogHandler.info('[DataSource] Fetching node detail...');
      LogHandler.info('API: /learningpaths/nodes/$nodeId');
      LogHandler.info('User ID: $userId');
      
      final response = await client.get(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId?user_id=$userId'),
        headers: await _getHeaders(),
      );

      LogHandler.info('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          LogHandler.info('Successfully fetched node detail: $nodeId');
          return NodeDetailApiModel.fromJson(data['data']);
        } on FormatException catch (e) {
          LogHandler.info('Failed to parse JSON response: $e');
          LogHandler.info('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response (possibly HTML error page)');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.info('Failed to get node detail: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get node detail');
        } on FormatException {
          LogHandler.info('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to get node detail (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      LogHandler.info('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.info('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.info('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.info('Exception in getNodeDetail: $e');
      throw Exception('Failed to fetch node detail: $e');
    }
  }

  Future<List<QuizQuestionApiModel>> getNodeQuestions(String nodeId) async {
    try {
      LogHandler.info('[DataSource] Fetching node questions...');
      LogHandler.info('API: /learningpaths/nodes/$nodeId/questions');
      
      final response = await client.get(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/questions'),
        headers: await _getHeaders(),
      );

      LogHandler.info('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final questions = data['data'] as List?;
        
        if (questions == null || questions.isEmpty) {
          LogHandler.info('No questions found for node: $nodeId (empty or null)');
          return [];
        }
        
        LogHandler.info('Successfully fetched ${questions.length} questions for node: $nodeId');

        return questions
            .map((question) => QuizQuestionApiModel.fromJson(question))
            .toList();
        } on FormatException catch (e) {
          LogHandler.info('Failed to parse JSON response: $e');
          LogHandler.info('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response (possibly HTML error page)');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.info('Failed to get questions: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get questions');
        } on FormatException {
          LogHandler.info('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to get questions (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      LogHandler.info('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.info('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.info('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.info('Exception in getNodeQuestions: $e');
      throw Exception('Failed to fetch questions: $e');
    }
  }

  Future<void> startNode(String nodeId, String userId) async {
    try {
      LogHandler.info('[DataSource] Starting node...');
      LogHandler.info('API: PUT /learningpaths/nodes/$nodeId/start');
      LogHandler.info('User ID: $userId');
      
      final response = await client.put(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/start?user_id=$userId'),
        headers: await _getHeaders(),
      );

      LogHandler.info('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        LogHandler.info('Successfully started node: $nodeId');
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.info('Failed to start node: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to start node');
        } on FormatException {
          LogHandler.info('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to start node (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      LogHandler.info('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.info('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.info('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.info('Exception in startNode: $e');
      throw Exception('Failed to start node: $e');
    }
  }

  Future<void> completeNode(String nodeId, String userId) async {
    try {
      LogHandler.info('[DataSource] Completing node...');
      LogHandler.info('API: PUT /learningpaths/nodes/$nodeId/complete');
      LogHandler.info('User ID: $userId');
      
      final response = await client.put(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/complete?user_id=$userId'),
        headers: await _getHeaders(),
      );

      LogHandler.info('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        LogHandler.info('Successfully completed node: $nodeId');
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.info('Failed to complete node: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to complete node');
        } on FormatException {
          LogHandler.info('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to complete node (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      LogHandler.info('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.info('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.info('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.info('Exception in completeNode: $e');
      throw Exception('Failed to complete node: $e');
    }
  }

  Future<void> enrollPath(String pathId, String userId) async {
    try {
      LogHandler.info('[DataSource] ========== ENROLLING IN PATH ==========');
      LogHandler.info('[DataSource] API: POST /learningpaths/$pathId/start');
      LogHandler.info('[DataSource] Path ID: $pathId');
      LogHandler.info('[DataSource] User ID: $userId');
      LogHandler.info('[DataSource] Request Body: ${jsonEncode({'user_id': userId})}');
      
      final response = await client.post(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/$pathId/start'),
        headers: await _getHeaders(),
        body: jsonEncode({'user_id': userId}),
      );

      LogHandler.info('[DataSource] Response Status: ${response.statusCode}');
      LogHandler.info('[DataSource] Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        LogHandler.info('[DataSource] Successfully enrolled in learning path: $pathId');
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.info('[DataSource] Error Response: $error');
          LogHandler.info('[DataSource] Error Message: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to enroll in learning path');
        } catch (e) {
          LogHandler.info('[DataSource] Failed to parse error response: $e');
          LogHandler.info('[DataSource] Raw response: ${response.body}');
          throw Exception('Failed to enroll (Status ${response.statusCode}): ${response.body}');
        }
      }
    } on SocketException catch (e) {
      LogHandler.info('[DataSource] No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.info('[DataSource] Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.info('[DataSource] HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.info('[DataSource] Exception in enrollPath: $e');
      rethrow;
    }
  }

  Future<void> deleteLearningPath(String pathId) async {
    try {
      LogHandler.info('[DataSource] Deleting learning path...');
      LogHandler.info('API: DELETE /learningpaths/$pathId');
      
      final response = await client.delete(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/$pathId'),
        headers: await _getHeaders(),
      );

      LogHandler.info('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        LogHandler.info('Successfully deleted learning path: $pathId');
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.info('Failed to delete learning path: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to delete learning path');
        } on FormatException {
          LogHandler.info('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to delete learning path (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      LogHandler.info('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.info('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.info('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.info('Exception in deleteLearningPath: $e');
      throw Exception('Failed to delete learning path: $e');
    }
  }
}
