import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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

class LearningPathDataSource {
  final http.Client client;

  LearningPathDataSource({http.Client? client})
    : client = client ?? http.Client();

  Future<List<LearningPathApiModel>> getAllLearningPaths() async {
    try {
      debugPrint('[DataSource] Fetching all learning paths...');
      debugPrint('API: ${ApiConfig.apiBaseUrl}/learningpaths');
      
      final response = await client.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final paths = data['data'] as List?;
        
        if (paths == null || paths.isEmpty) {
          debugPrint('No learning paths found (empty or null)');
          return [];
        }
        
        debugPrint('Successfully fetched ${paths.length} learning paths');
        
        return paths
            .map((path) => LearningPathApiModel.fromJson(path))
            .toList();
        } on FormatException catch (e) {
          debugPrint('Failed to parse JSON response: $e');
          debugPrint('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response (possibly HTML error page)');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          debugPrint('Failed to get learning paths: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get learning paths');
        } on FormatException {
          debugPrint('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to get learning paths (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in getAllLearningPaths: $e');
      throw Exception('Failed to fetch learning paths: $e');
    }
  }
  Future<LearningPathProgressApiModel> getLearningPathProgress(
    String pathId,
    String userId,
  ) async {
    try {
      debugPrint('[DataSource] Fetching learning path progress...');
      debugPrint('API: /user/learningpaths/$pathId/progress');
      debugPrint('User ID: $userId');
      
      final response = await client.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/user/learningpaths/$pathId/progress?user_id=$userId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          debugPrint('Successfully fetched progress for path: $pathId');
          return LearningPathProgressApiModel.fromJson(data['data']);
        } on FormatException catch (e) {
          debugPrint('Failed to parse JSON response: $e');
          debugPrint('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response (possibly HTML error page)');
        }
      } else {
        debugPrint('Failed to load progress');
        throw Exception('Failed to load progress');
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in getLearningPathProgress: $e');
      rethrow;
    }
  }
  Future<List<EnrolledLearningPathApiModel>> getEnrolledPaths(
    String userId,
  ) async {
    try {
      debugPrint('[DataSource] Fetching enrolled paths...');
      debugPrint('API: /learningpaths/user/enroll');
      debugPrint('User ID: $userId');
      
      final response = await client.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/learningpaths/user/enroll?user_id=$userId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final list = data['data'] as List?;
          
          if (list == null || list.isEmpty) {
            debugPrint('No enrolled paths found (empty or null)');
            return [];
          }
          
          debugPrint('Successfully fetched ${list.length} enrolled paths');
          
          return list.map((e) => EnrolledLearningPathApiModel.fromJson(e)).toList();
        } on FormatException catch (e) {
          debugPrint('Failed to parse JSON response: $e');
          debugPrint('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response (possibly HTML error page)');
        }
      } else {
        debugPrint('Failed to load enrolled paths');
        throw Exception('Failed to load enrolled paths');
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in getEnrolledPaths: $e');
      rethrow;
    }
  }

  Future<List<LearningNodeApiModel>> getNodesForPath(String pathId, String userId) async {
    try {
      debugPrint('[DataSource] Fetching nodes for path...');
      debugPrint('API: /learningpaths/$pathId/nodes');
      debugPrint('User ID: $userId');
      
      final response = await client.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/$pathId/nodes?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final nodes = data['data'] as List?;
        
        if (nodes == null || nodes.isEmpty) {
          debugPrint('No nodes found for path: $pathId (empty or null)');
          return [];
        }
        
        debugPrint('Successfully fetched ${nodes.length} nodes for path: $pathId');

        return nodes
            .map((node) => LearningNodeApiModel.fromJson(node))
            .toList();
        } on FormatException catch (e) {
          debugPrint('Failed to parse JSON response: $e');
          debugPrint('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response (possibly HTML error page)');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          debugPrint('Failed to get nodes: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get nodes');
        } on FormatException {
          debugPrint('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to get nodes (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in getNodesForPath: $e');
      throw Exception('Failed to fetch nodes: $e');
    }
  }

  Future<NodeDetailApiModel> getNodeDetail(String nodeId, String userId) async {
    try {
      debugPrint('[DataSource] Fetching node detail...');
      debugPrint('API: /learningpaths/nodes/$nodeId');
      debugPrint('User ID: $userId');
      
      final response = await client.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/nodes/$nodeId?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          debugPrint('Successfully fetched node detail: $nodeId');
          return NodeDetailApiModel.fromJson(data['data']);
        } on FormatException catch (e) {
          debugPrint('Failed to parse JSON response: $e');
          debugPrint('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response (possibly HTML error page)');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          debugPrint('Failed to get node detail: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get node detail');
        } on FormatException {
          debugPrint('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to get node detail (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in getNodeDetail: $e');
      throw Exception('Failed to fetch node detail: $e');
    }
  }

  Future<List<QuizQuestionApiModel>> getNodeQuestions(String nodeId) async {
    try {
      debugPrint('[DataSource] Fetching node questions...');
      debugPrint('API: /learningpaths/nodes/$nodeId/questions');
      
      final response = await client.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/nodes/$nodeId/questions'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final questions = data['data'] as List?;
        
        if (questions == null || questions.isEmpty) {
          debugPrint('No questions found for node: $nodeId (empty or null)');
          return [];
        }
        
        debugPrint('Successfully fetched ${questions.length} questions for node: $nodeId');

        return questions
            .map((question) => QuizQuestionApiModel.fromJson(question))
            .toList();
        } on FormatException catch (e) {
          debugPrint('Failed to parse JSON response: $e');
          debugPrint('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response (possibly HTML error page)');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          debugPrint('Failed to get questions: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get questions');
        } on FormatException {
          debugPrint('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to get questions (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in getNodeQuestions: $e');
      throw Exception('Failed to fetch questions: $e');
    }
  }

  Future<void> startNode(String nodeId, String userId) async {
    try {
      debugPrint('[DataSource] Starting node...');
      debugPrint('API: PUT /learningpaths/nodes/$nodeId/start');
      debugPrint('User ID: $userId');
      
      final response = await client.put(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/nodes/$nodeId/start?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Successfully started node: $nodeId');
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          debugPrint('Failed to start node: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to start node');
        } on FormatException {
          debugPrint('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to start node (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in startNode: $e');
      throw Exception('Failed to start node: $e');
    }
  }

  Future<void> completeNode(String nodeId, String userId) async {
    try {
      debugPrint('[DataSource] Completing node...');
      debugPrint('API: PUT /learningpaths/nodes/$nodeId/complete');
      debugPrint('User ID: $userId');
      
      final response = await client.put(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/nodes/$nodeId/complete?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Successfully completed node: $nodeId');
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          debugPrint('Failed to complete node: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to complete node');
        } on FormatException {
          debugPrint('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to complete node (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in completeNode: $e');
      throw Exception('Failed to complete node: $e');
    }
  }

  Future<void> enrollPath(String pathId, String userId) async {
    try {
      debugPrint('[DataSource] ========== ENROLLING IN PATH ==========');
      debugPrint('[DataSource] API: POST /learningpaths/$pathId/start');
      debugPrint('[DataSource] Path ID: $pathId');
      debugPrint('[DataSource] User ID: $userId');
      debugPrint('[DataSource] Request Body: ${jsonEncode({'user_id': userId})}');
      
      final response = await client.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/$pathId/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      debugPrint('[DataSource] Response Status: ${response.statusCode}');
      debugPrint('[DataSource] Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[DataSource] Successfully enrolled in learning path: $pathId');
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          debugPrint('[DataSource] Error Response: $error');
          debugPrint('[DataSource] Error Message: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to enroll in learning path');
        } catch (e) {
          debugPrint('[DataSource] Failed to parse error response: $e');
          debugPrint('[DataSource] Raw response: ${response.body}');
          throw Exception('Failed to enroll (Status ${response.statusCode}): ${response.body}');
        }
      }
    } on SocketException catch (e) {
      debugPrint('[DataSource] No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('[DataSource] Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('[DataSource] HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('[DataSource] Exception in enrollPath: $e');
      rethrow;
    }
  }

  Future<void> deleteLearningPath(String pathId) async {
    try {
      debugPrint('[DataSource] Deleting learning path...');
      debugPrint('API: DELETE /learningpaths/$pathId');
      
      final response = await client.delete(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/$pathId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Successfully deleted learning path: $pathId');
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          debugPrint('Failed to delete learning path: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to delete learning path');
        } on FormatException {
          debugPrint('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to delete learning path (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in deleteLearningPath: $e');
      throw Exception('Failed to delete learning path: $e');
    }
  }

  // ===== TEACHER FEATURES =====

  Future<String> createLearningPath(CreatePathRequestApiModel request) async {
    try {
      debugPrint('[DataSource] Creating learning path...');
      debugPrint('API: POST /learningpaths');
      debugPrint('Request: ${jsonEncode(request.toJson())}');
      
      final response = await client.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          final pathId = data['data']['path_id'] ?? data['data']['PathID'] ?? '';
          debugPrint('Successfully created learning path: $pathId');
          return pathId;
        } on FormatException catch (e) {
          debugPrint('Failed to parse JSON response: $e');
          debugPrint('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          debugPrint('Failed to create learning path: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to create learning path');
        } on FormatException {
          debugPrint('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to create learning path (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in createLearningPath: $e');
      rethrow;
    }
  }

  Future<String> createNode(CreateNodeRequestApiModel request) async {
    try {
      debugPrint('[DataSource] Creating node...');
      debugPrint('API: POST /learningpaths/${request.pathId}/nodes');
      debugPrint('Request: ${jsonEncode(request.toJson())}');
      
      final response = await client.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/${request.pathId}/nodes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          final nodeId = data['data']['node_id'] ?? data['data']['NodeID'] ?? '';
          debugPrint('Successfully created node: $nodeId');
          return nodeId;
        } on FormatException catch (e) {
          debugPrint('Failed to parse JSON response: $e');
          debugPrint('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          debugPrint('Failed to create node: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to create node');
        } on FormatException {
          debugPrint('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to create node (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in createNode: $e');
      rethrow;
    }
  }

  Future<AIGenerateResponseApiModel> generateNodesWithAI(String topic) async {
    try {
      debugPrint('[DataSource] Generating nodes with AI...');
      debugPrint('API: POST /learningpaths/generate');
      debugPrint('Topic: $topic');
      
      final response = await client.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'topic': topic}),
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          debugPrint('Successfully generated nodes for topic: $topic');
          return AIGenerateResponseApiModel.fromJson(data['data'] ?? data);
        } on FormatException catch (e) {
          debugPrint('Failed to parse JSON response: $e');
          debugPrint('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          debugPrint('Failed to generate nodes: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to generate nodes');
        } on FormatException {
          debugPrint('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to generate nodes (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in generateNodesWithAI: $e');
      rethrow;
    }
  }

  Future<LearningPathApiModel> getLearningPathById(String pathId) async {
    try {
      debugPrint('[DataSource] Fetching learning path by ID...');
      debugPrint('API: GET /learningpaths/$pathId');
      
      final response = await client.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/$pathId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          debugPrint('Successfully fetched learning path: $pathId');
          return LearningPathApiModel.fromJson(data['data']);
        } on FormatException catch (e) {
          debugPrint('Failed to parse JSON response: $e');
          debugPrint('Raw response body: ${response.body}');
          throw Exception('Server returned invalid JSON response');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          debugPrint('Failed to get learning path: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get learning path');
        } on FormatException {
          debugPrint('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to get learning path (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in getLearningPathById: $e');
      rethrow;
    }
  }

  Future<void> updateNode(String nodeId, String title, String description) async {
    try {
      debugPrint('[DataSource] Updating node...');
      debugPrint('API: PUT /nodes/$nodeId');
      debugPrint('Request: title=$title, description=$description');
      
      final response = await client.put(
        Uri.parse('${ApiConfig.apiBaseUrl}/nodes/$nodeId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
      );

      debugPrint('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Successfully updated node: $nodeId');
        return;
      } else {
        try {
          final error = jsonDecode(response.body);
          debugPrint('Failed to update node: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to update node');
        } on FormatException {
          debugPrint('Failed to parse error response. Raw body: ${response.body}');
          throw Exception('Failed to update node (Status ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      debugPrint('Exception in updateNode: $e');
      rethrow;
    }
  }
}
