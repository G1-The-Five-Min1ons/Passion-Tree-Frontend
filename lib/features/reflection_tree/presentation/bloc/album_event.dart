import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AlbumEvent extends Equatable {
  const AlbumEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load albums for a specific user
class LoadAlbumsEvent extends AlbumEvent {
  final String userId;

  const LoadAlbumsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to create a new album
class CreateAlbumEvent extends AlbumEvent {
  final String userId;
  final String albumName;
  final File? coverImage;

  const CreateAlbumEvent({
    required this.userId,
    required this.albumName,
    this.coverImage,
  });

  @override
  List<Object?> get props => [userId, albumName, coverImage?.path];
}

/// Event to update an existing album
class UpdateAlbumEvent extends AlbumEvent {
  final String albumId;
  final String userId;
  final String albumName;
  final File? coverImage;
  final String? existingImageUrl;

  const UpdateAlbumEvent({
    required this.albumId,
    required this.userId,
    required this.albumName,
    this.coverImage,
    this.existingImageUrl,
  });

  @override
  List<Object?> get props => [albumId, userId, albumName, coverImage?.path, existingImageUrl];
}

/// Event to delete an album
class DeleteAlbumEvent extends AlbumEvent {
  final String albumId;
  final String userId;

  const DeleteAlbumEvent({
    required this.albumId,
    required this.userId,
  });

  @override
  List<Object?> get props => [albumId, userId];
}

/// Event to load a specific album by ID
class LoadAlbumByIdEvent extends AlbumEvent {
  final String albumId;

  const LoadAlbumByIdEvent(this.albumId);

  @override
  List<Object?> get props => [albumId];
}

/// Event to refresh albums
class RefreshAlbumsEvent extends AlbumEvent {
  final String userId;

  const RefreshAlbumsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
