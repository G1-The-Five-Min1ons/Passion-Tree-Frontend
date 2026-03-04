import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/comment_api_model.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

class CommentRemoteDataSource {
  final http.Client client;

  CommentRemoteDataSource({http.Client? client})
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

  Future<List<CommentApiModel>> getNodeComments(String nodeId) async {
    try {
      LogHandler.debug('[DataSource] GET /learningpaths/nodes/$nodeId/comments');

      final response = await client.get(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/comments',
        ),
        headers: await _getHeaders(),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final comments = data['data'] as List?;

        if (comments == null || comments.isEmpty) return [];

        return comments.map((json) => CommentApiModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to get comments (Status ${response.statusCode})',
        );
      }
    } catch (e) {
      LogHandler.error('Exception in getNodeComments: $e');
      throw Exception('Failed to fetch comments: $e');
    }
  }

  Future<List<CommentApiModel>> getPathComments(String pathId) async {
    try {
      LogHandler.debug('[DataSource] GET /learningpaths/$pathId/comments');

      final response = await client.get(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/$pathId/comments'),
        headers: await _getHeaders(),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final comments = data['data'] as List?;

        if (comments == null || comments.isEmpty) return [];

        return comments.map((json) => CommentApiModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to get path comments (Status ${response.statusCode})',
        );
      }
    } catch (e) {
      LogHandler.error('Exception in getPathComments: $e');
      throw Exception('Failed to fetch path comments: $e');
    }
  }

  Future<CommentApiModel> createComment(
    String nodeId,
    String message, {
    String? parentId,
  }) async {
    try {
      LogHandler.debug('[DataSource] POST /learningpaths/nodes/$nodeId/comments');

      final response = await client.post(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/comments',
        ),
        headers: await _getHeaders(),
        body: jsonEncode({
          'node_id': nodeId,
          'message': message,
          if (parentId != null) 'parent_id': parentId,
        }),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CommentApiModel.fromJson(data['data']);
      } else {
        LogHandler.error('Create Comment Error (Status ${response.statusCode})');
        throw Exception(
          'Failed to create comment (Status ${response.statusCode})',
        );
      }
    } catch (e) {
      LogHandler.error('Exception in createComment: $e');
      throw Exception('Failed to create comment: $e');
    }
  }

  Future<CommentApiModel> createPathComment(
    String pathId,
    String message, {
    String? parentId,
  }) async {
    try {
      LogHandler.debug('[DataSource] POST /learningpaths/$pathId/comments');

      final response = await client.post(
        Uri.parse('${ApiConfig.apiBackendUrl}/learningpaths/$pathId/comments'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'path_id': pathId,
          'message': message,
          if (parentId != null) 'parent_id': parentId,
        }),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CommentApiModel.fromJson(data['data']);
      } else {
        LogHandler.error('Create Path Comment Error (Status ${response.statusCode})');
        throw Exception(
          'Failed to create path comment (Status ${response.statusCode})',
        );
      }
    } catch (e) {
      LogHandler.error('Exception in createPathComment: $e');
      throw Exception('Failed to create path comment: $e');
    }
  }

  Future<CommentApiModel> updateComment(
    String commentId,
    String message,
  ) async {
    try {
      LogHandler.debug('[DataSource] PUT /learningpaths/comments/$commentId');

      final response = await client.put(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/comments/$commentId',
        ),
        headers: await _getHeaders(),
        body: jsonEncode({'message': message}),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CommentApiModel.fromJson(data['data']);
      } else {
        throw Exception(
          'Failed to update comment (Status ${response.statusCode})',
        );
      }
    } catch (e) {
      LogHandler.error('Exception in updateComment: $e');
      throw Exception('Failed to update comment: $e');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      LogHandler.debug('[DataSource] DELETE /learningpaths/comments/$commentId');

      final response = await client.delete(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/comments/$commentId',
        ),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete comment (Status ${response.statusCode})',
        );
      }
    } catch (e) {
      LogHandler.error('Exception in deleteComment: $e');
      throw Exception('Failed to delete comment: $e');
    }
  }

  Future<void> addReaction(String commentId, String reactionType) async {
    try {
      LogHandler.debug('[DataSource] POST /learningpaths/comments/$commentId/reactions');

      final response = await client.post(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/comments/$commentId/reactions',
        ),
        headers: await _getHeaders(),
        body: jsonEncode({'reaction_type': reactionType}),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to add reaction (Status ${response.statusCode})',
        );
      }
    } catch (e) {
      LogHandler.error('Exception in addReaction: $e');
      throw Exception('Failed to add reaction: $e');
    }
  }
}
