import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/usecases/album_usecases.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';

enum AlbumOperationType { created, updated, deleted }

class AlbumOperationResult {
  final AlbumOperationType type;
  final Album? album;

  AlbumOperationResult(this.type, {this.album});
}

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final GetAlbumsByUserIdUseCase getAlbumsByUserId;
  final GetAlbumByIdUseCase getAlbumById;
  final CreateAlbumUseCase createAlbum;
  final UpdateAlbumUseCase updateAlbum;
  final DeleteAlbumUseCase deleteAlbum;

  final _albumOperationController = StreamController<AlbumOperationResult>.broadcast();
  Stream<AlbumOperationResult> get albumOperationStream => _albumOperationController.stream;

  AlbumBloc({
    required this.getAlbumsByUserId,
    required this.getAlbumById,
    required this.createAlbum,
    required this.updateAlbum,
    required this.deleteAlbum,
  }) : super(AlbumInitial()) {
    on<LoadAlbumsEvent>(_onLoadAlbums);
    on<LoadAlbumByIdEvent>(_onLoadAlbumById);
    on<CreateAlbumEvent>(_onCreateAlbum);
    on<UpdateAlbumEvent>(_onUpdateAlbum);
    on<DeleteAlbumEvent>(_onDeleteAlbum);
    on<RefreshAlbumsEvent>(_onRefreshAlbums);
  }

  Future<void> _onLoadAlbums(
    LoadAlbumsEvent event,
    Emitter<AlbumState> emit,
  ) async {
    emit(AlbumLoading());
    try {
      final albums = await getAlbumsByUserId(event.userId);
      emit(AlbumsLoaded(albums));
    } catch (e) {
      emit(AlbumError('Failed to load albums: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAlbumById(
    LoadAlbumByIdEvent event,
    Emitter<AlbumState> emit,
  ) async {
    emit(AlbumLoading());
    try {
      final album = await getAlbumById(event.albumId);
      emit(AlbumDetailLoaded(album));
    } catch (e) {
      emit(AlbumError('Failed to load album: ${e.toString()}'));
    }
  }

  Future<void> _onCreateAlbum(
    CreateAlbumEvent event,
    Emitter<AlbumState> emit,
  ) async {
    if (state is AlbumsLoaded) {
      final currentAlbums = (state as AlbumsLoaded).albums;
      emit(AlbumOperationLoading(currentAlbums: currentAlbums));
    } else {
      emit(AlbumLoading());
    }

    try {
      final album = await createAlbum(
        userId: event.userId,
        albumName: event.albumName,
        coverImageUrl: event.coverImageUrl,
      );
      
      debugPrint('[AlbumBloc] Album created successfully!');
      debugPrint(' Album ID: ${album.id}');
      debugPrint('Album Title: ${album.title}');
      
      _albumOperationController.add(
        AlbumOperationResult(AlbumOperationType.created, album: album),
      );
      
      final albums = await getAlbumsByUserId(event.userId);
      emit(AlbumsLoaded(albums));
    } catch (e) {
      debugPrint('[AlbumBloc] Failed to create album: $e');
      emit(AlbumError('Failed to create album: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAlbum(
    UpdateAlbumEvent event,
    Emitter<AlbumState> emit,
  ) async {
    if (state is AlbumsLoaded) {
      final currentAlbums = (state as AlbumsLoaded).albums;
      emit(AlbumOperationLoading(currentAlbums: currentAlbums));
    } else {
      emit(AlbumLoading());
    }

    try {
      await updateAlbum(
        albumId: event.albumId,
        albumName: event.albumName,
        coverImageUrl: event.coverImageUrl,
      );
      
      _albumOperationController.add(
        AlbumOperationResult(AlbumOperationType.updated),
      );
      
      final album = await getAlbumById(event.albumId);
      emit(AlbumDetailLoaded(album));
    } catch (e) {
      emit(AlbumError('Failed to update album: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAlbum(
    DeleteAlbumEvent event,
    Emitter<AlbumState> emit,
  ) async {
    if (state is AlbumsLoaded) {
      final currentAlbums = (state as AlbumsLoaded).albums;
      emit(AlbumOperationLoading(currentAlbums: currentAlbums));
    } else {
      emit(AlbumLoading());
    }

    try {
      await deleteAlbum(event.albumId);
      
      _albumOperationController.add(
        AlbumOperationResult(AlbumOperationType.deleted),
      );
      
      if (state is AlbumsLoaded) {
        final currentState = state as AlbumsLoaded;
        final updatedAlbums = currentState.albums
            .where((album) => album.id != event.albumId)
            .toList();
        emit(AlbumsLoaded(updatedAlbums));
      }
    } catch (e) {
      emit(AlbumError('Failed to delete album: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshAlbums(
    RefreshAlbumsEvent event,
    Emitter<AlbumState> emit,
  ) async {
    try {
      final albums = await getAlbumsByUserId(event.userId);
      emit(AlbumsLoaded(albums));
    } catch (e) {
      emit(AlbumError('Failed to refresh albums: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _albumOperationController.close();
    return super.close();
  }
}
