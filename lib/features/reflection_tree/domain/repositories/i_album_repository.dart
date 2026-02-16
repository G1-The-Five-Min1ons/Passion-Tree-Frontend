import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';

abstract class IAlbumRepository {
  /// Create a new album
  Future<Album> createAlbum({
    required String userId,
    required String albumName,
    required String coverImageUrl,
  });

  /// Get album by ID
  Future<Album> getAlbumById(String albumId);

  /// Get all albums by user ID
  Future<List<Album>> getAlbumsByUserId(String userId);

  /// Update album
  Future<void> updateAlbum({
    required String albumId,
    required String albumName,
    required String coverImageUrl,
  });

  /// Delete album
  Future<void> deleteAlbum(String albumId);
}
