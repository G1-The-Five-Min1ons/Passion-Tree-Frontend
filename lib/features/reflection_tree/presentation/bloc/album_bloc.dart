import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/usecases/album_usecases.dart';

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
      emit(AlbumsLoaded([]));
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
      emit(AlbumCreated(album));
      
      final albums = await getAlbumsByUserId(event.userId);
      emit(AlbumsLoaded(albums));
    } catch (e) {
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
      emit(AlbumUpdated());
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
      emit(AlbumDeleted());
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
      emit(AlbumsLoaded([]));
    }
  }
}
