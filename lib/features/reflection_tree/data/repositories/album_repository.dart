import 'package:passion_tree_frontend/features/reflection_tree/data/datasources/album_data_source.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/models/album_api_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/mappers/album_mapper.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/album_model.dart';

class AlbumRepository {
  final AlbumDataSource dataSource;

  AlbumRepository({AlbumDataSource? dataSource})
      : dataSource = dataSource ?? AlbumDataSource();

  /// Create a new album
  Future<Album> createAlbum({
    required String userId,
    required String albumName,
    required String coverImageUrl,
  }) async {
    final request = CreateAlbumRequest(
      userId: userId,
      albumName: albumName,
      coverImageUrl: coverImageUrl,
    );
    final apiModel = await dataSource.createAlbum(request);
    return AlbumMapper.toAlbum(apiModel);
  }

  /// Get album by ID
  Future<Album> getAlbumById(String albumId) async {
    final apiModel = await dataSource.getAlbumById(albumId);
    return AlbumMapper.toAlbum(apiModel);
  }

  /// Get all albums by user ID
  Future<List<Album>> getAlbumsByUserId(String userId) async {
    final apiModels = await dataSource.getAlbumsByUserId(userId);
    return AlbumMapper.toAlbumList(apiModels);
  }

  /// Update album
  Future<void> updateAlbum({
    required String albumId,
    required String albumName,
    required String coverImageUrl,
  }) async {
    final request = UpdateAlbumRequest(
      albumName: albumName,
      coverImageUrl: coverImageUrl,
    );
    return await dataSource.updateAlbum(albumId, request);
  }

  /// Delete album
  Future<void> deleteAlbum(String albumId) async {
    return await dataSource.deleteAlbum(albumId);
  }
}
