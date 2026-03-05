import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/repositories/i_album_repository.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';

/// Use case for creating a new album
class CreateAlbumUseCase {
  final IAlbumRepository repository;
  final AuthLocalDataSource authLocalDataSource;

  CreateAlbumUseCase(this.repository, this.authLocalDataSource);

  Future<Either<Failure, Album>> call({
    required String title,
    File? coverImage,
  }) async {
    final userId = await authLocalDataSource.getUserId();
    if (userId == null) {
      return Left(AuthFailure.unauthorized(
        message: 'User not authenticated',
      ));
    }
    
    return await repository.createAlbum(
      userId: userId,
      title: title,
      coverImage: coverImage,
    );
  }
}

/// Use case for getting albums by user ID
class GetAlbumsByUserIdUseCase {
  final IAlbumRepository repository;
  final AuthLocalDataSource authLocalDataSource;

  GetAlbumsByUserIdUseCase(this.repository, this.authLocalDataSource);

  Future<Either<Failure, List<Album>>> call() async {
    final userId = await authLocalDataSource.getUserId();
    if (userId == null) {
      return Left(AuthFailure.unauthorized(
        message: 'User not authenticated',
      ));
    }
    
    return await repository.getAlbumsByUserId(userId);
  }
}

/// Use case for getting album by ID
class GetAlbumByIdUseCase {
  final IAlbumRepository repository;

  GetAlbumByIdUseCase(this.repository);

  Future<Either<Failure, Album>> call(String albumId) async {
    return await repository.getAlbumById(albumId);
  }
}

/// Use case for updating an album
class UpdateAlbumUseCase {
  final IAlbumRepository repository;

  UpdateAlbumUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String albumId,
    required String title,
    File? coverImage,
  }) async {
    return await repository.updateAlbum(
      albumId: albumId,
      title: title,
      coverImage: coverImage,
    );
  }
}

/// Use case for deleting an album
class DeleteAlbumUseCase {
  final IAlbumRepository repository;

  DeleteAlbumUseCase(this.repository);

  Future<Either<Failure, void>> call(String albumId) async {
    return await repository.deleteAlbum(albumId);
  }
}

/// Use case for creating a new tree
class CreateTreeUseCase {
  final IAlbumRepository repository;

  CreateTreeUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String title,
    required String difficulties,
    required String pathId,
    required String albumId,
  }) async {
    return await repository.createTree(
      title: title,
      difficulties: difficulties,
      pathId: pathId,
      albumId: albumId,
    );
  }
}

/// Use case for deleting a tree
class DeleteTreeUseCase {
  final IAlbumRepository repository;

  DeleteTreeUseCase(this.repository);

  Future<Either<Failure, void>> call(String treeId) async {
    return await repository.deleteTree(treeId);
  }
}

/// Use case for updating a tree
class UpdateTreeUseCase {
  final IAlbumRepository repository;

  UpdateTreeUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String treeId,
    required String title,
    String? albumId,
  }) async {
    return await repository.updateTree(
      treeId: treeId,
      title: title,
      albumId: albumId,
    );
  }
}
