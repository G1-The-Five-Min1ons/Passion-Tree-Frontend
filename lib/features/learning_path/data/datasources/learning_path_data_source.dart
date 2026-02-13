import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_path_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_path_progress_api_model.dart';

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
        '${ApiConfig.baseUrl}/api/v1/user/learningpaths/$pathId/progress?user_id=$userId',
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

}
