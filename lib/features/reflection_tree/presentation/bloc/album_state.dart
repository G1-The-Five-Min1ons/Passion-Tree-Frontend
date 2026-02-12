import 'package:equatable/equatable.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/album_model.dart';

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

  const AlbumsLoaded(this.albums);

  @override
  List<Object?> get props => [albums];
}

/// State when a single album is loaded
class AlbumDetailLoaded extends AlbumState {
  final Album album;

  const AlbumDetailLoaded(this.album);

  @override
  List<Object?> get props => [album];
}

/// State when album is created successfully
class AlbumCreated extends AlbumState {
  final Album album;

  const AlbumCreated(this.album);

  @override
  List<Object?> get props => [album];
}

class AlbumUpdated extends AlbumState {}

class AlbumDeleted extends AlbumState {}

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
