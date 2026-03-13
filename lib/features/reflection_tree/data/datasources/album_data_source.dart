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
            if (response.data == null) {
        LogHandler.error('Response data is null');
        throw createExceptionFromStatusCode(500, 'Server returned null data');
      }
      
      final data = response.data as Map<String, dynamic>;
      return TreeApiModel.fromJson(data);
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

  /// Update a tree
  Future<void> updateTree(String treeId, String title, String? albumId, String token) async {
    LogHandler.separator(title: 'TREE · UPDATE');
    
    final Map<String, dynamic> requestBody = {'title': title};
    if (albumId != null && albumId.isNotEmpty) {
      requestBody['album_id'] = albumId;
    }
    
    final response = await _apiHandler.put(
      url: ApiConfig.treeById(treeId),
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode(requestBody),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess) {
      LogHandler.success('Tree updated: $treeId');
      return;
    }

    final msg = response.error ?? response.message ?? 'Failed to update tree';
    LogHandler.error('Update tree failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  /// Get nodes by learning path ID
  Future<List<LearningPathNode>> getNodesByPathId(String pathId, String token) async {
    LogHandler.separator(title: 'NODES · GET BY PATH');
    final response = await _apiHandler.get(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/$pathId/nodes',
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess) {
      List nodes = [];
      
      // Handle both response formats
      if (response.data is List) {
        nodes = response.data as List;
      } else if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        nodes = data['data'] as List? ?? [];
      }
      
      LogHandler.success('Fetched ${nodes.length} node(s) for path: $pathId');
      return nodes.map((node) => LearningPathNode.fromJson(node)).toList();
    }

    final msg = response.error ?? response.message ?? 'Failed to get nodes';
    LogHandler.error('Get nodes failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  Future<String> createNodeInPath(
    String pathId,
    String title,
    String description,
    String sequence,
    String token,
  ) async {
    LogHandler.separator(title: 'NODE · CREATE IN PATH');
    final response = await _apiHandler.post(
      url: '${ApiConfig.apiBackendUrl}/learningpaths/$pathId/nodes',
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode({
        'title': title,
        'description': description,
        'sequence': sequence,
      }),
      timeout: ApiConfig.connectionTimeout,
    );

    LogHandler.debug('Response status: ${response.statusCode}');
    LogHandler.debug('Response data type: ${response.data.runtimeType}');
    LogHandler.debug('Response data: ${response.data}');

    if (response.isSuccess && response.statusCode == 201) {
      LogHandler.success('Node created in learning path');
      
      // Handle different response formats
      String nodeId;
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        
        if (data.containsKey('data') && data['data'] != null) {
          if (data['data'] is Map) {
            nodeId = data['data']['node_id'] as String;
          } else {
            throw Exception('Unexpected data structure: data is not a Map');
          }
        } else if (data.containsKey('node_id')) {
          nodeId = data['node_id'] as String;
        } else {
          throw Exception('node_id not found in response: $data');
        }
      } else {
        throw Exception('Unexpected response type: ${response.data.runtimeType}');
      }
      
      LogHandler.info('Created node_id: $nodeId');
      return nodeId;
    }

    final msg = response.error ?? response.message ?? 'Failed to create node';
    LogHandler.error('Create node failed: $msg');
    LogHandler.error('Response status: ${response.statusCode}');
    LogHandler.error('Response body: ${response.data}');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  /// Create a tree node (link node from learning path to tree)
  Future<TreeNodeApiModel> createTreeNode(CreateTreeNodeRequest request, String token) async {
    LogHandler.separator(title: 'TREE NODE · CREATE');
    LogHandler.debug('Request: ${request.toJson()}');
    
    final response = await _apiHandler.post(
      url: ApiConfig.treeNodes,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode(request.toJson()),
      timeout: ApiConfig.connectionTimeout,
    );

    LogHandler.debug('Response status: ${response.statusCode}');
    LogHandler.debug('Response data type: ${response.data.runtimeType}');
    LogHandler.debug('Response data: ${response.data}');

    if (response.isSuccess && response.statusCode == 201) {
      LogHandler.success('Tree node created successfully');
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        
        // Try different possible structures
        Map<String, dynamic>? treeNodeData;
        
        if (data.containsKey('data') && data['data'] != null) {
          final dataField = data['data'];
          if (dataField is Map<String, dynamic>) {
            if (dataField.containsKey('tree_node')) {
              treeNodeData = dataField['tree_node'] as Map<String, dynamic>;
            } else {
              // data itself might be the tree node
              treeNodeData = dataField;
            }
          }
        } else if (data.containsKey('tree_node')) {
          treeNodeData = data['tree_node'] as Map<String, dynamic>;
        } else {
          // The whole response might be the tree node
          treeNodeData = data;
        }
        
        if (treeNodeData != null) {
          return TreeNodeApiModel.fromJson(treeNodeData);
        } else {
          throw Exception('Could not find tree node data in response: $data');
        }
      } else {
        throw Exception('Unexpected response type: ${response.data.runtimeType}');
      }
    }

    final msg = response.error ?? response.message ?? 'Failed to create tree node';
    LogHandler.error('Create tree node failed: $msg');
    LogHandler.error('Response status: ${response.statusCode}');
    LogHandler.error('Response data: ${response.data}');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  /// Get tree nodes by tree ID
  Future<List<TreeNodeApiModel>> getTreeNodesByTreeId(String treeId, String token) async {
    LogHandler.separator(title: 'TREE NODES · GET BY TREE');
    final response = await _apiHandler.get(
      url: ApiConfig.treeNodesByTreeId(treeId),
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess) {
      final data = response.data as Map<String, dynamic>;
      final nodes = data['data'] as List? ?? [];
      LogHandler.success('Fetched ${nodes.length} tree node(s) for tree: $treeId');
      return nodes.map((node) => TreeNodeApiModel.fromJson(node)).toList();
    }

    final msg = response.error ?? response.message ?? 'Failed to get tree nodes';
    LogHandler.error('Get tree nodes failed: $msg');
    final statusCode = response.statusCode;
    throw createExceptionFromStatusCode(statusCode, msg);
  }

  void dispose() {
    _apiHandler.dispose();
  }
}
