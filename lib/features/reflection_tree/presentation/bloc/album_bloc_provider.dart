import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/repositories/album_repository.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/usecases/album_usecases.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';

class AlbumBlocProvider extends StatelessWidget {
  final Widget child;

  const AlbumBlocProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final repository = AlbumRepository();

    return BlocProvider(
      create: (context) => AlbumBloc(
        getAlbumsByUserId: GetAlbumsByUserIdUseCase(repository),
        getAlbumById: GetAlbumByIdUseCase(repository),
        createAlbum: CreateAlbumUseCase(repository),
        updateAlbum: UpdateAlbumUseCase(repository),
        deleteAlbum: DeleteAlbumUseCase(repository),
      ),
      child: child,
    );
  }
}