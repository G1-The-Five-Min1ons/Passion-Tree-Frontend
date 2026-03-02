import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/usecases/album_usecases.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final GetAlbumsByUserIdUseCase getAlbumsByUserId;
  final GetAlbumByIdUseCase getAlbumById;
  final CreateAlbumUseCase createAlbum;
  final UpdateAlbumUseCase updateAlbum;
  final DeleteAlbumUseCase deleteAlbum;

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
    on<ClearAlbumErrorEvent>(_onClearAlbumError);
  }

  Future<void> _onLoadAlbums(
    LoadAlbumsEvent event,
    Emitter<AlbumState> emit,
  ) async {
    emit(AlbumLoading());
    
    final result = await getAlbumsByUserId();
    
    result.fold(
      (failure) {
        LogHandler.error('Failed to load albums: ${failure.message}');
        emit(AlbumError(failure.message));
      },
      (albums) {
        LogHandler.success('Loaded ${albums.length} albums');
        emit(AlbumsLoaded(albums));
      },
    );
  }

  Future<void> _onLoadAlbumById(
    LoadAlbumByIdEvent event,
    Emitter<AlbumState> emit,
  ) async {
    emit(AlbumLoading());
    
    final result = await getAlbumById(event.albumId);
    
    result.fold(
      (failure) {
        LogHandler.error('Failed to load album: ${failure.message}');
        emit(AlbumError(failure.message));
      },
      (album) {
        LogHandler.success('Loaded album: ${album.albumId}');
        emit(AlbumDetailLoaded(album));
      },
    );
  }

  Future<void> _onCreateAlbum(
    CreateAlbumEvent event,
    Emitter<AlbumState> emit,
  ) async {
    List<Album>? currentAlbums;
    if (state is AlbumsLoaded) {
      currentAlbums = (state as AlbumsLoaded).albums;
    }

    // Show uploading state if image is provided
    if (event.coverImage != null) {
      emit(ImageUploading(currentAlbums: currentAlbums));
    } else {
      emit(AlbumOperationLoading(currentAlbums: currentAlbums));
    }

    // Create album (repository handles upload internally)
    final createResult = await createAlbum(
      title: event.title,
      coverImage: event.coverImage,
    );
    
    await createResult.fold(
      (failure) {
        LogHandler.error('Failed to create album: ${failure.message}');
        emit(AlbumError(failure.message));
      },
      (album) async {
        LogHandler.success('Album created: ${album.albumId} — ${album.title}');
        
        // Reload albums with success message
        final albumsResult = await getAlbumsByUserId();
        albumsResult.fold(
          (failure) => emit(AlbumError(failure.message)),
          (albums) => emit(AlbumsLoaded(
            albums,
            message: 'Album "${album.title}" created successfully',
          )),
        );
      },
    );
  }

  Future<void> _onUpdateAlbum(
    UpdateAlbumEvent event,
    Emitter<AlbumState> emit,
  ) async {
    List<Album>? currentAlbums;
    if (state is AlbumsLoaded) {
      currentAlbums = (state as AlbumsLoaded).albums;
    }

    // Show uploading state if image is provided
    if (event.coverImage != null) {
      emit(ImageUploading(currentAlbums: currentAlbums));
    } else {
      emit(AlbumOperationLoading(currentAlbums: currentAlbums));
    }

    // Update album (repository handles upload internally)
    final updateResult = await updateAlbum(
      albumId: event.albumId,
      title: event.title,
      coverImage: event.coverImage,
    );
    
    await updateResult.fold(
      (failure) {
        LogHandler.error('Failed to update album: ${failure.message}');
        emit(AlbumError(failure.message));
      },
      (_) async {
        LogHandler.success('Album updated: ${event.albumId}');
        
        // Reload albums with success message
        final albumsResult = await getAlbumsByUserId();
        albumsResult.fold(
          (failure) => emit(AlbumError(failure.message)),
          (albums) => emit(AlbumsLoaded(
            albums,
            message: 'Album updated successfully',
          )),
        );
      },
    );
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

    final deleteResult = await deleteAlbum(event.albumId);
    
    await deleteResult.fold(
      (failure) {
        LogHandler.error('Failed to delete album: ${failure.message}');
        emit(AlbumError(failure.message));
      },
      (_) async {
        LogHandler.success('Album deleted: ${event.albumId}');
        
        // Reload albums with success message
        final albumsResult = await getAlbumsByUserId();
        albumsResult.fold(
          (failure) => emit(AlbumError(failure.message)),
          (albums) => emit(AlbumsLoaded(
            albums,
            message: 'Album deleted successfully',
          )),
        );
      },
    );
  }

  Future<void> _onRefreshAlbums(
    RefreshAlbumsEvent event,
    Emitter<AlbumState> emit,
  ) async {
    final result = await getAlbumsByUserId();
    
    result.fold(
      (failure) {
        LogHandler.error('Failed to refresh albums: ${failure.message}');
        emit(AlbumError(failure.message));
      },
      (albums) {
        LogHandler.success('Albums refreshed');
        emit(AlbumsLoaded(albums));
      },
    );
  }

  void _onClearAlbumError(
    ClearAlbumErrorEvent event,
    Emitter<AlbumState> emit,
  ) {
    LogHandler.info('Clearing album error state');
    emit(AlbumInitial());
  }
}
