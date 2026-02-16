import 'package:passion_tree_frontend/features/reflection_tree/domain/repositories/i_album_repository.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';

/// Use case for creating a new album
class CreateAlbumUseCase {
  final IAlbumRepository repository;

  CreateAlbumUseCase(this.repository);

  Future<Album> call({
    required String userId,
    required String albumName,
    required String coverImageUrl,
  }) async {
    return await repository.createAlbum(
      userId: userId,
      albumName: albumName,
      coverImageUrl: coverImageUrl,
    );
  }
}

/// Use case for getting albums by user ID
class GetAlbumsByUserIdUseCase {
  final IAlbumRepository repository;

  GetAlbumsByUserIdUseCase(this.repository);

  Future<List<Album>> call(String userId) async {
    return await repository.getAlbumsByUserId(userId);
  }
}

/// Use case for getting album by ID
class GetAlbumByIdUseCase {
  final IAlbumRepository repository;

  GetAlbumByIdUseCase(this.repository);

  Future<Album> call(String albumId) async {
    return await repository.getAlbumById(albumId);
  }
}

/// Use case for updating an album
class UpdateAlbumUseCase {
  final IAlbumRepository repository;

  UpdateAlbumUseCase(this.repository);

  Future<void> call({
    required String albumId,
    required String albumName,
    required String coverImageUrl,
  }) async {
    return await repository.updateAlbum(
      albumId: albumId,
      albumName: albumName,
      coverImageUrl: coverImageUrl,
    );
  }
}

/// Use case for deleting an album
class DeleteAlbumUseCase {
  final IAlbumRepository repository;

  DeleteAlbumUseCase(this.repository);

  Future<void> call(String albumId) async {
    return await repository.deleteAlbum(albumId);
  }
}
