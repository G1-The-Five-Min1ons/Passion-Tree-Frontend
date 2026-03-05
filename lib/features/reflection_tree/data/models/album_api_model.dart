import 'package:passion_tree_frontend/core/error/exceptions.dart';

class AlbumApiModel {
  final String albumId;
  final String albumName;
  final int treeCount;
  final String coverImageUrl;
  final DateTime createdAt;
  final DateTime lastEdit;
  final String userId;

  AlbumApiModel({
    required this.albumId,
    required this.albumName,
    required this.treeCount,
    required this.coverImageUrl,
    required this.createdAt,
    required this.lastEdit,
    required this.userId,
  });

  factory AlbumApiModel.fromJson(Map<String, dynamic> json) {
    try {
      return AlbumApiModel(
        albumId: json['album_id'] ?? '',
        albumName: json['album_name'] ?? '',
        treeCount: json['tree_count'] ?? 0,
        coverImageUrl: json['cover_image_url'] ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
        lastEdit: json['last_edit'] != null
            ? DateTime.parse(json['last_edit'])
            : DateTime.now(),
        userId: json['user_id'] ?? '',
      );
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse AlbumApiModel',
        originalError: e,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'album_id': albumId,
      'album_name': albumName,
      'tree_count': treeCount,
      'cover_image_url': coverImageUrl,
      'created_at': createdAt.toIso8601String(),
      'last_edit': lastEdit.toIso8601String(),
      'user_id': userId,
    };
  }
}

class CreateAlbumRequest {
  final String userId;
  final String albumName;
  final String coverImageUrl;

  CreateAlbumRequest({
    required this.userId,
    required this.albumName,
    required this.coverImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'album_name': albumName,
      'cover_image_url': coverImageUrl,
    };
  }
}

class UpdateAlbumRequest {
  final String albumName;
  final String coverImageUrl;

  UpdateAlbumRequest({
    required this.albumName,
    required this.coverImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'album_name': albumName,
      'cover_image_url': coverImageUrl,
    };
  }
}

class CreateTreeRequest {
  final String title;
  final String difficulties;
  final String pathId;
  final String albumId;

  CreateTreeRequest({
    required this.title,
    required this.difficulties,
    required this.pathId,
    required this.albumId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'difficulties': difficulties,
      'path_id': pathId,
      'album_id': albumId,
    };
  }
}

class TreeApiModel {
  final String treeId;
  final String title;
  final String difficulties;
  final String pathId;
  final String status;
  final bool isPause;
  final int nodeCount;
  final DateTime createdAt;
  final DateTime lastUpdate;
  final String albumId;
  final List<TreeNodeApiModel>? nodes;

  TreeApiModel({
    required this.treeId,
    required this.title,
    required this.difficulties,
    required this.pathId,
    required this.status,
    required this.isPause,
    required this.nodeCount,
    required this.createdAt,
    required this.lastUpdate,
    required this.albumId,
    this.nodes,
  });

  factory TreeApiModel.fromJson(Map<String, dynamic> json) {
    try {
      List<TreeNodeApiModel>? nodesList;
      if (json['nodes'] != null) {
        final nodesJson = json['nodes'] as List;
        nodesList = nodesJson.map((node) => TreeNodeApiModel.fromJson(node)).toList();
      }

      return TreeApiModel(
        treeId: json['tree_id'] ?? '',
        title: json['title'] ?? '',
        difficulties: json['difficulties'] ?? '',
        pathId: json['path_id'] ?? '',
        status: json['status'] ?? 'active',
        isPause: json['is_pause'] ?? false,
        nodeCount: json['node_count'] ?? 0,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
        lastUpdate: json['last_update'] != null
            ? DateTime.parse(json['last_update'])
            : DateTime.now(),
        albumId: json['album_id'] ?? '',
        nodes: nodesList,
      );
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse TreeApiModel',
        originalError: e,
      );
    }
  }
}

class TreeNodeApiModel {
  final String treeNodeId;
  final String nodeTitle;
  final String nodeId;
  final double? nodeScore;
  final DateTime createdAt;
  final String treeId;
  final String? childNode;
  final int sequence;

  TreeNodeApiModel({
    required this.treeNodeId,
    required this.nodeTitle,
    required this.nodeId,
    this.nodeScore,
    required this.createdAt,
    required this.treeId,
    this.childNode,
    required this.sequence,
  });

  factory TreeNodeApiModel.fromJson(Map<String, dynamic> json) {
    try {
      return TreeNodeApiModel(
        treeNodeId: json['tree_node_id'] ?? '',
        nodeTitle: json['node_title'] ?? '',
        nodeId: json['node_id'] ?? '',
        nodeScore: json['node_score'] != null ? (json['node_score'] as num).toDouble() : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
        treeId: json['tree_id'] ?? '',
        childNode: json['child_node'],
        sequence: json['sequence'] ?? 0,
      );
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse TreeNodeApiModel',
        originalError: e,
      );
    }
  }
}
