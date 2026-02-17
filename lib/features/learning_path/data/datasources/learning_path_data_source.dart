import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_path_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_path_progress_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/enrolled_learning_path_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_node_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/node_detail_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/quiz_question_api_model.dart';

class LearningPathDataSource {
  final http.Client client;

  LearningPathDataSource({http.Client? client})
    : client = client ?? http.Client();

  Future<List<LearningPathApiModel>> getAllLearningPaths() async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final paths = data['data'] as List;

        return paths
            .map((path) => LearningPathApiModel.fromJson(path))
            .toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get learning paths');
      }
    } catch (e) {
      throw Exception('Failed to fetch learning paths: $e');
    }
  }
  Future<LearningPathProgressApiModel> getLearningPathProgress(
    String pathId,
    String userId,
  ) async {
    final response = await client.get(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/user/learningpaths/$pathId/progress?user_id=$userId',
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LearningPathProgressApiModel.fromJson(data['data']);
    } else {
      throw Exception('Failed to load progress');
    }
  }
  Future<List<EnrolledLearningPathApiModel>> getEnrolledPaths(
    String userId,
  ) async {
    final response = await client.get(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/learningpaths/user/enroll?user_id=$userId',
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data'] as List;

      return list.map((e) => EnrolledLearningPathApiModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load enrolled paths');
    }
  }

  Future<List<LearningNodeApiModel>> getNodesForPath(String pathId, String userId) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/$pathId/nodes?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nodes = data['data'] as List;

        return nodes
            .map((node) => LearningNodeApiModel.fromJson(node))
            .toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get nodes');
      }
    } catch (e) {
      throw Exception('Failed to fetch nodes: $e');
    }
  }

  Future<NodeDetailApiModel> getNodeDetail(String nodeId, String userId) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/nodes/$nodeId?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NodeDetailApiModel.fromJson(data['data']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get node detail');
      }
    } catch (e) {
      throw Exception('Failed to fetch node detail: $e');
    }
  }

  Future<List<QuizQuestionApiModel>> getNodeQuestions(String nodeId) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/nodes/$nodeId/questions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final questions = data['data'] as List;

        return questions
            .map((question) => QuizQuestionApiModel.fromJson(question))
            .toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get questions');
      }
    } catch (e) {
      throw Exception('Failed to fetch questions: $e');
    }
  }

  Future<void> startNode(String nodeId, String userId) async {
    try {
      final response = await client.put(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/nodes/$nodeId/start?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to start node');
      }
    } catch (e) {
      throw Exception('Failed to start node: $e');
    }
  }

  Future<void> completeNode(String nodeId, String userId) async {
    try {
      final response = await client.put(
        Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/nodes/$nodeId/complete?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to complete node');
      }
    } catch (e) {
      throw Exception('Failed to complete node: $e');
    }
  }
}
