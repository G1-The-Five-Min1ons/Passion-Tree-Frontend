import 'package:passion_tree_frontend/features/reflection_tree/data/datasources/album_data_source.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/models/album_api_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/mappers/album_mapper.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/repositories/i_album_repository.dart';
import 'package:passion_tree_frontend/features/authentication/data/services/token_storage_service.dart';

class AlbumRepository implements IAlbumRepository {
  final AlbumDataSource dataSource;
  final TokenStorageService tokenStorage;

  AlbumRepository({
    AlbumDataSource? dataSource,
    TokenStorageService? tokenStorage,
  })  : dataSource = dataSource ?? AlbumDataSource(),
        tokenStorage = tokenStorage ?? TokenStorageService();

  @override
  Future<Album> createAlbum({
    required String userId,
    required String albumName,
    required String coverImageUrl,
  }) async {
    try {
      final token = await tokenStorage.getToken();
      if (token == null) throw Exception('No authentication token found');
      
      final request = CreateAlbumRequest(
        userId: userId,
        albumName: albumName,
        coverImageUrl: coverImageUrl,
      );
      final apiModel = await dataSource.createAlbum(request, token);
      return AlbumMapper.toAlbum(apiModel);
    } catch (e) {
      throw Exception('Failed to create album: $e');
    }
  }

  @override
  Future<Album> getAlbumById(String albumId) async {
    try {
      final token = await tokenStorage.getToken();
      if (token == null) throw Exception('No authentication token found');
      
      final apiModel = await dataSource.getAlbumById(albumId, token);
      return AlbumMapper.toAlbum(apiModel);
    } catch (e) {
      throw Exception('Failed to get album: $e');
    }
  }

  @override
  Future<List<Album>> getAlbumsByUserId(String userId) async {
    try {
      final token = await tokenStorage.getToken();
      if (token == null) throw Exception('No authentication token found');
      
      final apiModels = await dataSource.getAlbumsByUserId(userId, token);
      return AlbumMapper.toAlbumList(apiModels);
    } catch (e) {
      throw Exception('Failed to get albums: $e');
    }
  }

  @override
  Future<void> updateAlbum({
    required String albumId,
    required String albumName,
    required String coverImageUrl,
  }) async {
    try {
      final token = await tokenStorage.getToken();
      if (token == null) throw Exception('No authentication token found');
      
      final request = UpdateAlbumRequest(
        albumName: albumName,
        coverImageUrl: coverImageUrl,
      );
      await dataSource.updateAlbum(albumId, request, token);
    } catch (e) {
      throw Exception('Failed to update album: $e');
    }
  }

  @override
  Future<void> deleteAlbum(String albumId) async {
    try {
      final token = await tokenStorage.getToken();
      if (token == null) throw Exception('No authentication token found');
      
      await dataSource.deleteAlbum(albumId, token);
    } catch (e) {
      throw Exception('Failed to delete album: $e');
    }
  }
}
