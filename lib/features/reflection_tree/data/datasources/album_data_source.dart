import 'dart:convert';
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/core/network/api_handler.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/core/error/exceptions.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/models/album_api_model.dart';

class AlbumDataSource {
  final ApiHandler _apiHandler;

  AlbumDataSource({ApiHandler? apiHandler})
      : _apiHandler = apiHandler ?? ApiHandler();

  /// Create a new album
  Future<AlbumApiModel> createAlbum(CreateAlbumRequest request, String token) async {
    LogHandler.separator(title: 'ALBUM · CREATE');
    final response = await _apiHandler.post(
      url: ApiConfig.albums,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess && response.statusCode == 201) {
      LogHandler.success('Album created successfully');
      final data = response.data as Map<String, dynamic>;
      return AlbumApiModel.fromJson(data['album']);
    }

    final msg = response.error ?? response.message ?? 'Failed to create album';
    LogHandler.error('Create album failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  /// Get album by ID
  Future<AlbumApiModel> getAlbumById(String albumId, String token) async {
    LogHandler.separator(title: 'ALBUM · GET BY ID');
    final response = await _apiHandler.get(
      url: ApiConfig.albumById(albumId),
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess) {
      LogHandler.success('Album fetched: $albumId');
      final data = response.data as Map<String, dynamic>;
      return AlbumApiModel.fromJson(data['album']);
    }

    final msg = response.error ?? response.message ?? 'Failed to get album';
    LogHandler.error('Get album failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  /// Get all albums by user ID
  Future<List<AlbumApiModel>> getAlbumsByUserId(String userId, String token) async {
    LogHandler.separator(title: 'ALBUM · GET BY USER');
    final response = await _apiHandler.get(
      url: ApiConfig.albumsByUserId(userId),
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess) {
      final data = response.data as Map<String, dynamic>;
      final albums = data['albums'] as List? ?? [];
      LogHandler.success('Fetched ${albums.length} album(s) for user: $userId');
      return albums.map((album) => AlbumApiModel.fromJson(album)).toList();
    }

    final msg = response.error ?? response.message ?? 'Failed to get albums';
    LogHandler.error('Get albums failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  /// Update album
  Future<void> updateAlbum(String albumId, UpdateAlbumRequest request, String token) async {
    LogHandler.separator(title: 'ALBUM · UPDATE');
    final response = await _apiHandler.put(
      url: ApiConfig.albumById(albumId),
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess) {
      LogHandler.success('Album updated: $albumId');
      return;
    }

    final msg = response.error ?? response.message ?? 'Failed to update album';
    LogHandler.error('Update album failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  /// Delete album
  Future<void> deleteAlbum(String albumId, String token) async {
    LogHandler.separator(title: 'ALBUM · DELETE');
    final response = await _apiHandler.delete(
      url: ApiConfig.albumById(albumId),
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess) {
      LogHandler.success('Album deleted: $albumId');
      return;
    }

    final msg = response.error ?? response.message ?? 'Failed to delete album';
    LogHandler.error('Delete album failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  /// Get trees by album ID
  Future<List<TreeApiModel>> getTreesByAlbumId(String albumId, String token) async {
    LogHandler.separator(title: 'TREE · GET BY ALBUM');
    final response = await _apiHandler.get(
      url: '${ApiConfig.treesByAlbumId(albumId)}&include_nodes=true',
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess) {
      final data = response.data as Map<String, dynamic>;
      final trees = data['trees'] as List? ?? [];
      LogHandler.success('Fetched ${trees.length} tree(s) for album: $albumId');
      return trees.map((tree) => TreeApiModel.fromJson(tree)).toList();
    }

    final msg = response.error ?? response.message ?? 'Failed to get trees';
    LogHandler.error('Get trees failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  /// Create a new tree
  Future<TreeApiModel> createTree(CreateTreeRequest request, String token) async {
    LogHandler.separator(title: 'TREE · CREATE');
    final response = await _apiHandler.post(
      url: ApiConfig.trees,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess && response.statusCode == 201) {
      LogHandler.success('Tree created successfully');
      final data = response.data as Map<String, dynamic>;
      return TreeApiModel.fromJson(data['tree']);
    }

    final msg = response.error ?? response.message ?? 'Failed to create tree';
    LogHandler.error('Create tree failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  /// Delete a tree
  Future<void> deleteTree(String treeId, String token) async {
    LogHandler.separator(title: 'TREE · DELETE');
    final response = await _apiHandler.delete(
      url: ApiConfig.treeById(treeId),
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess) {
      LogHandler.success('Tree deleted: $treeId');
      return;
    }

    final msg = response.error ?? response.message ?? 'Failed to delete tree';
    LogHandler.error('Delete tree failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  void dispose() {
    _apiHandler.dispose();
  }
}
