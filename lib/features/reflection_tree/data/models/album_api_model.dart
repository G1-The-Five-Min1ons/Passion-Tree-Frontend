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
