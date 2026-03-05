import 'package:equatable/equatable.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';

abstract class AlbumState extends Equatable {
  const AlbumState();

  @override
  List<Object?> get props => [];
}

class AlbumInitial extends AlbumState {}

class AlbumLoading extends AlbumState {}

/// State when albums are loaded successfully
class AlbumsLoaded extends AlbumState {
  final List<Album> albums;
  final String? message;

  const AlbumsLoaded(
    this.albums,
    {this.message});

  @override
  List<Object?> get props => [albums, message];
}

/// State when a single album is loaded
class AlbumDetailLoaded extends AlbumState {
  final Album album;
  final String? message;

  const AlbumDetailLoaded(this.album, {this.message});

  @override
  List<Object?> get props => [album, message];
}

/// Error state
class AlbumError extends AlbumState {
  final String message;

  const AlbumError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Loading state for operations (create, update, delete)
class AlbumOperationLoading extends AlbumState {
  final List<Album>? currentAlbums;

  const AlbumOperationLoading({this.currentAlbums});

  @override
  List<Object?> get props => [currentAlbums];
}

/// State when uploading image
class ImageUploading extends AlbumState {
  final List<Album>? currentAlbums;

  const ImageUploading({this.currentAlbums});

  @override
  List<Object?> get props => [currentAlbums];
}

class TreeCreated extends AlbumState {
  final String treeId;
  final String message;

  const TreeCreated({
    required this.treeId,
    this.message = 'Tree created successfully',
  });

  @override
  List<Object?> get props => [treeId, message];
}
