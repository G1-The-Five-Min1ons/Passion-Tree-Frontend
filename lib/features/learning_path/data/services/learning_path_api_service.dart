import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_path_request.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/ai_generate_model.dart';

Future createLearningPath(CreatePathRequest request) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/learningpaths');

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

Future<AIGenerateResponse> generatePathWithAI(String topic) async {
  // เดาว่า endpoint คือ /learningpaths/generate หรือ /ai/generate
  // (เช็คกับ Backend อีกทีนะครับว่า route จริงๆ ชื่ออะไร)
  final url = Uri.parse('${ApiConfig.baseUrl}/learningpaths/generate');

  try {
    final response = await http.post(
      url,
      // headers: ApiConfig.defaultHeaders, // ใส่ token ถ้าต้องใช้
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'topic': topic}), // ส่งหัวข้อไปให้ AI คิด
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // เข้าถึง path: data -> (topic, nodes) ตามรูป json
      return AIGenerateResponse.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to generate path: ${response.body}');
    }
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> getLearningPathById(String pathId) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/learningpaths/$pathId');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    // return ข้อมูลใน data กลับไป (ตามโครงสร้าง json ในรูปที่คุณส่งมา)
    return jsonResponse['data'];
  } else {
    throw Exception(
      'Failed to load learning path details: ${response.statusCode}',
    );
  }
}
