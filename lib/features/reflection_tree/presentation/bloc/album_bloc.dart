import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/usecases/album_usecases.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/core/services/upload_service.dart';
import 'package:path/path.dart' as path;

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
    List<Album>? currentAlbums;
    if (state is AlbumsLoaded) {
      currentAlbums = (state as AlbumsLoaded).albums;
    }

    try {
      String coverImageUrl = '';

      // Upload image if provided
      if (event.coverImage != null) {
        emit(ImageUploading(currentAlbums: currentAlbums));
        
        debugPrint('[AlbumBloc] Uploading image...');
        final uploadService = UploadApiService();
        final fileName = path.basename(event.coverImage!.path);
        
        final urls = await uploadService.getPresignedUrl(
          fileName,
          'reflect',
        );
        
        await uploadService.uploadFileToBlob(
          urls['upload_url']!,
          event.coverImage!,
        );
        
        coverImageUrl = urls['public_url']!;
        debugPrint('[AlbumBloc] Image uploaded successfully');
      }

      emit(AlbumOperationLoading(currentAlbums: currentAlbums));

      final album = await createAlbum(
        userId: event.userId,
        albumName: event.albumName,
        coverImageUrl: coverImageUrl,
      );
      
      debugPrint('[AlbumBloc] Album created successfully!');
      debugPrint(' Album ID: ${album.albumId}');
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
    List<Album>? currentAlbums;
    if (state is AlbumsLoaded) {
      currentAlbums = (state as AlbumsLoaded).albums;
      emit(AlbumOperationLoading(currentAlbums: currentAlbums));
    } else {
      emit(AlbumLoading());
    }

    try {
      String coverImageUrl = event.existingImageUrl ?? '';

      // Upload new image if provided
      if (event.coverImage != null) {
        emit(ImageUploading(currentAlbums: currentAlbums));
        
        debugPrint('[AlbumBloc] Uploading new image...');
        final uploadService = UploadApiService();
        final fileName = path.basename(event.coverImage!.path);
        
        final urls = await uploadService.getPresignedUrl(
          fileName,
          'reflect',
        );
        
        await uploadService.uploadFileToBlob(
          urls['upload_url']!,
          event.coverImage!,
        );
        
        coverImageUrl = urls['public_url']!;
        debugPrint('[AlbumBloc] Image uploaded successfully');
        
        emit(AlbumOperationLoading(currentAlbums: currentAlbums));
      }

      await updateAlbum(
        albumId: event.albumId,
        albumName: event.albumName,
        coverImageUrl: coverImageUrl,
      );
      
      debugPrint('[AlbumBloc] Album updated successfully!');
      
      _albumOperationController.add(
        AlbumOperationResult(AlbumOperationType.updated),
      );
      
      // Reload albums for the user
      final albums = await getAlbumsByUserId(event.userId);
      emit(AlbumsLoaded(albums));
    } catch (e) {
      debugPrint('[AlbumBloc] Failed to update album: $e');
      emit(AlbumError('Failed to update album: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAlbum(
    DeleteAlbumEvent event,
    Emitter<AlbumState> emit,
  ) async {
    List<Album>? currentAlbums;
    
    if (state is AlbumsLoaded) {
      currentAlbums = (state as AlbumsLoaded).albums;
      emit(AlbumOperationLoading(currentAlbums: currentAlbums));
    } else {
      emit(AlbumLoading());
    }

    try {
      await deleteAlbum(event.albumId);
      
      _albumOperationController.add(
        AlbumOperationResult(AlbumOperationType.deleted),
      );
      
      if (currentAlbums != null) {
        final updatedAlbums = currentAlbums
            .where((album) => album.albumId != event.albumId)
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
