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
      LogHandler.info('[DataSource] Fetching comments for node $nodeId...');

      final response = await client.get(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/nodes/$nodeId/comments',
        ),
        headers: await _getHeaders(),
      );

      LogHandler.info('Response Status: ${response.statusCode}');

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
      LogHandler.info('Exception in getNodeComments: $e');
      throw Exception('Failed to fetch comments: $e');
    }
  }

  Future<CommentApiModel> createComment(
    String nodeId,
    String message, {
    String? parentId,
  }) async {
    try {
      LogHandler.info('[DataSource] Creating comment for node $nodeId...');

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

      LogHandler.info('Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CommentApiModel.fromJson(data['data']);
      } else {
        LogHandler.info('Create Comment Error Body: ${response.body}');
        throw Exception(
          'Failed to create comment (Status ${response.statusCode})',
        );
      }
    } catch (e) {
      LogHandler.info('Exception in createComment: $e');
      throw Exception('Failed to create comment: $e');
    }
  }

  Future<CommentApiModel> updateComment(
    String commentId,
    String message,
  ) async {
    try {
      LogHandler.info('[DataSource] Updating comment $commentId...');

      final response = await client.put(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/comments/$commentId',
        ),
        headers: await _getHeaders(),
        body: jsonEncode({'message': message}),
      );

      LogHandler.info('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CommentApiModel.fromJson(data['data']);
      } else {
        throw Exception(
          'Failed to update comment (Status ${response.statusCode})',
        );
      }
    } catch (e) {
      LogHandler.info('Exception in updateComment: $e');
      throw Exception('Failed to update comment: $e');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      LogHandler.info('[DataSource] Deleting comment $commentId...');

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
      LogHandler.info('Exception in deleteComment: $e');
      throw Exception('Failed to delete comment: $e');
    }
  }

  Future<void> addReaction(String commentId, String reactionType) async {
    try {
      LogHandler.info('[DataSource] Adding reaction to comment $commentId...');

      final response = await client.post(
        Uri.parse(
          '${ApiConfig.apiBackendUrl}/learningpaths/comments/$commentId/reactions',
        ),
        headers: await _getHeaders(),
        body: jsonEncode({'reaction_type': reactionType}),
      );

      LogHandler.info('Response Status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to add reaction (Status ${response.statusCode})',
        );
      }
    } catch (e) {
      LogHandler.info('Exception in addReaction: $e');
      throw Exception('Failed to add reaction: $e');
    }
  }
}
