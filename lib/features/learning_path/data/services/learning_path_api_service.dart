import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_path_request.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/ai_generate_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_node_request.dart';

Future createLearningPath(CreatePathRequest request) async {
  final url = Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      debugPrint('Created Successfully: ${response.body}');
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['data']['path_id'].toString();
    } else {
      throw Exception('Failed to create path: ${response.body}');
    }
  } catch (e) {
    rethrow;
  }
}

Future<AIGenerateResponse> generateNodeWithAI(String topic) async {
  final url = Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/generate');

  try {
    final response = await http.post(
      url,
      // headers: ApiConfig.defaultHeaders, // ใส่ token ถ้าต้องใช้
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'topic': topic}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return AIGenerateResponse.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to generate path: ${response.body}');
    }
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> getLearningPathById(String pathId) async {
  final url = Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/$pathId');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['data'];
  } else {
    throw Exception(
      'Failed to load learning path details: ${response.statusCode}',
    );
  }
}

Future<String> createNodeApi(CreateNodeRequest request) async {
  final url = Uri.parse('${ApiConfig.apiBaseUrl}/learningpaths/${request.pathId}/nodes');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['data']['node_id'].toString();
    } else {
      throw Exception('Failed to create node: ${response.body}');
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> updateNodeApi(String nodeId, String title, String description) async {
  final url = Uri.parse('${ApiConfig.apiBaseUrl}/nodes/$nodeId');
  
  final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"title": title, "description": description}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update node: ${response.body}');
  }
}
