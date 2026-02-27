import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AlbumEvent extends Equatable {
  const AlbumEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load albums for a specific user
class LoadAlbumsEvent extends AlbumEvent {
  const LoadAlbumsEvent();
}

/// Event to create a new album
class CreateAlbumEvent extends AlbumEvent {
  final String title;
  final File? coverImage;

  const CreateAlbumEvent({
    required this.title,
    this.coverImage,
  });

  @override
  List<Object?> get props => [title, coverImage?.path];
}

/// Event to update an existing album
class UpdateAlbumEvent extends AlbumEvent {
  final String albumId;
  final String title;
  final File? coverImage;
  final String? existingImageUrl;

  const UpdateAlbumEvent({
    required this.albumId,
    required this.title,
    this.coverImage,
    this.existingImageUrl,
  });

  @override
  List<Object?> get props => [albumId, title, coverImage?.path, existingImageUrl];
}

/// Event to delete an album
class DeleteAlbumEvent extends AlbumEvent {
  final String albumId;

  const DeleteAlbumEvent(this.albumId);

  @override
  List<Object?> get props => [albumId];
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
  const RefreshAlbumsEvent();
}

/// Event to clear error state
class ClearAlbumErrorEvent extends AlbumEvent {
  const ClearAlbumErrorEvent();
}
