import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:path/path.dart' as path;
import 'package:passion_tree_frontend/core/error/failure_mapper.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/services/upload_service.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/datasources/album_data_source.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/models/album_api_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/mappers/album_mapper.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/mappers/tree_mapper.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/repositories/i_album_repository.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/core/error/exceptions.dart';

class AlbumRepository implements IAlbumRepository {
  final AlbumDataSource dataSource;
  final AuthLocalDataSource authLocalDataSource;
  final UploadApiService uploadService;

  AlbumRepository({
    required this.dataSource,
    required this.authLocalDataSource,
    required this.uploadService,
  });

  Future<Either<Failure, String>> _getValidToken() async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        LogHandler.error('No authentication token found');
        return Left(AuthFailure.unauthorized(
          message: 'No authentication token found',
        ));
      }
      return Right(token);
    } catch (e) {
      LogHandler.error('Failed to get token', error: e);
      return Left(AuthFailure(
        message: 'Failed to retrieve authentication',
        technicalMessage: e.toString(),
      ));
    }
  }

  /// Upload image to blob storage and return public URL
  Future<Either<Failure, String>> _uploadImage(File imageFile) async {
    try {
      LogHandler.info('Uploading album cover image...');
      
      final fileName = path.basename(imageFile.path);
      final bytes = await imageFile.readAsBytes();
      final urls = await uploadService.getPresignedUrl(fileName, 'reflect');
      await uploadService.uploadFileToBlob(urls['upload_url']!, bytes, fileName);
      
      final publicUrl = urls['public_url']!;
      LogHandler.success('Album cover uploaded successfully');
      
      return Right(publicUrl);
    } catch (e) {
      LogHandler.error('Failed to upload image', error: e);
      return Left(ServerFailure(
        message: 'ไม่สามารถอัพโหลดรูปภาพได้',
        technicalMessage: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Album>> createAlbum({
    required String userId,
    required String title,
    File? coverImage,
  }) async {
    try {
      final tokenResult = await _getValidToken();
      return tokenResult.fold(
        (failure) => Left(failure), // Return auth failure
        (token) async {
          // Upload image if provided
          String coverImageUrl = '';
          if (coverImage != null) {
            final uploadResult = await _uploadImage(coverImage);
            // If upload failed, return the failure immediately
            final uploadUrlOrFailure = uploadResult.fold(
              (failure) => null,
              (url) => url,
            );
            
            if (uploadUrlOrFailure == null) {
              // Return failure from upload
              return uploadResult.fold(
                (failure) => Left(failure),
                (_) => Left(UnknownFailure(message: 'Upload failed')),
              );
            }
            coverImageUrl = uploadUrlOrFailure;
          }
          
          // Proceed with album creation
          final request = CreateAlbumRequest(
            userId: userId,
            albumName: title,
            coverImageUrl: coverImageUrl,
          );
          final apiModel = await dataSource.createAlbum(request, token);
          return Right(AlbumMapper.toAlbum(apiModel));
        },
      );
    } on AppException catch (e) {
      return Left(FailureMapper.fromException(e));
    } catch (e) {
      LogHandler.error('Repository: create album failed', error: e);
      return Left(UnknownFailure(
        message: 'Failed to create album',
        technicalMessage: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Album>> getAlbumById(String albumId) async {
    try {
      final tokenResult = await _getValidToken();
      return tokenResult.fold(
        (failure) => Left(failure),
        (token) async {
          final albumApiModel = await dataSource.getAlbumById(albumId, token);
          final treesApiModels = await dataSource.getTreesByAlbumId(albumId, token);
          
          final items = TreeMapper.toAlbumItemList(treesApiModels);
          
          return Right(AlbumMapper.toAlbumWithItems(albumApiModel, items));
        },
      );
    } on AppException catch (e) {
      return Left(FailureMapper.fromException(e));
    } catch (e) {
      LogHandler.error('Repository: get album failed', error: e);
      return Left(UnknownFailure(
        message: 'Failed to get album',
        technicalMessage: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, List<Album>>> getAlbumsByUserId(String userId) async {
    try {
      final tokenResult = await _getValidToken();
      return tokenResult.fold(
        (failure) => Left(failure),
        (token) async {
          final apiModels = await dataSource.getAlbumsByUserId(userId, token);
          return Right(AlbumMapper.toAlbumList(apiModels));
        },
      );
    } on AppException catch (e) {
      return Left(FailureMapper.fromException(e));
    } catch (e) {
      LogHandler.error('Repository: get albums failed', error: e);
      return Left(UnknownFailure(
        message: 'Failed to get albums',
        technicalMessage: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateAlbum({
    required String albumId,
    required String title,
    File? coverImage,
  }) async {
    try {
      final tokenResult = await _getValidToken();
      return tokenResult.fold(
        (failure) => Left(failure),
        (token) async {
          // Upload image if provided
          String coverImageUrl = '';
          if (coverImage != null) {
            final uploadResult = await _uploadImage(coverImage);
            // If upload failed, return the failure immediately
            final uploadUrlOrFailure = uploadResult.fold(
              (failure) => null,
              (url) => url,
            );
            
            if (uploadUrlOrFailure == null) {
              // Return failure from upload
              return uploadResult.fold(
                (failure) => Left(failure),
                (_) => Left(UnknownFailure(message: 'Upload failed')),
              );
            }
            coverImageUrl = uploadUrlOrFailure;
          }
          
          final request = UpdateAlbumRequest(
            albumName: title,
            coverImageUrl: coverImageUrl,
          );
          await dataSource.updateAlbum(albumId, request, token);
          return const Right(null);
        },
      );
    } on AppException catch (e) {
      return Left(FailureMapper.fromException(e));
    } catch (e) {
      LogHandler.error('Repository: update album failed', error: e);
      return Left(UnknownFailure(
        message: 'Failed to update album',
        technicalMessage: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAlbum(String albumId) async {
    try {
      final tokenResult = await _getValidToken();
      return tokenResult.fold(
        (failure) => Left(failure),
        (token) async {
          await dataSource.deleteAlbum(albumId, token);
          return const Right(null);
        },
      );
    } on AppException catch (e) {
      return Left(FailureMapper.fromException(e));
    } catch (e) {
      LogHandler.error('Repository: delete album failed', error: e);
      return Left(UnknownFailure(
        message: 'Failed to delete album',
        technicalMessage: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, String>> createTree({
    required String title,
    required String difficulties,
    required String pathId,
    required String albumId,
  }) async {
    try {
      final tokenResult = await _getValidToken();
      return tokenResult.fold(
        (failure) => Left(failure),
        (token) async {
          final request = CreateTreeRequest(
            title: title,
            difficulties: difficulties,
            pathId: pathId,
            albumId: albumId,
          );
          
          final tree = await dataSource.createTree(request, token);
          LogHandler.success('Tree created with ID: ${tree.treeId}');
          
          return Right(tree.treeId);
        },
      );
    } on AppException catch (e) {
      return Left(FailureMapper.fromException(e));
    } catch (e) {
      LogHandler.error('Repository: create tree failed', error: e);
      return Left(UnknownFailure(
        message: 'Failed to create tree',
        technicalMessage: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTree(String treeId) async {
    try {
      final tokenResult = await _getValidToken();
      return tokenResult.fold(
        (failure) => Left(failure),
        (token) async {
          await dataSource.deleteTree(treeId, token);
          return const Right(null);
        },
      );
    } on AppException catch (e) {
      return Left(FailureMapper.fromException(e));
    } catch (e) {
      LogHandler.error('Repository: delete tree failed', error: e);
      return Left(UnknownFailure(
        message: 'Failed to delete tree',
        technicalMessage: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateTree({
    required String treeId,
    required String title,
    String? albumId,
  }) async {
    try {
      final tokenResult = await _getValidToken();
      return tokenResult.fold(
        (failure) => Left(failure),
        (token) async {
          await dataSource.updateTree(treeId, title, albumId, token);
          LogHandler.success('Tree updated successfully');
          return const Right(null);
        },
      );
    } on AppException catch (e) {
      return Left(FailureMapper.fromException(e));
    } catch (e) {
      LogHandler.error('Repository: update tree failed', error: e);
      return Left(UnknownFailure(
        message: 'Failed to update tree',
        technicalMessage: e.toString(),
      ));
    }
  }
}
