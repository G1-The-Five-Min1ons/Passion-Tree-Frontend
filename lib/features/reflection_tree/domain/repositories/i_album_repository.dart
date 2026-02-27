import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';

abstract class IAlbumRepository {
  /// Create a new album
  Future<Either<Failure, Album>> createAlbum({
    required String userId,
    required String title,
    File? coverImage,
  });

  /// Get album by ID
  Future<Either<Failure, Album>> getAlbumById(String albumId);

  /// Get all albums by user ID
  Future<Either<Failure, List<Album>>> getAlbumsByUserId(String userId);

  /// Update album
  Future<Either<Failure, void>> updateAlbum({
    required String albumId,
    required String title,
    File? coverImage,
  });

  /// Delete album
  Future<Either<Failure, void>> deleteAlbum(String albumId);
}
