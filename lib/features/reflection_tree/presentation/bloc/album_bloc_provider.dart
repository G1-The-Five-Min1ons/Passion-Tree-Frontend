import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
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
    return BlocProvider(
      create: (context) => AlbumBloc(
        getAlbumsByUserId: getIt<GetAlbumsByUserIdUseCase>(),
        getAlbumById: getIt<GetAlbumByIdUseCase>(),
        createAlbum: getIt<CreateAlbumUseCase>(),
        updateAlbum: getIt<UpdateAlbumUseCase>(),
        deleteAlbum: getIt<DeleteAlbumUseCase>(),
        createTree: getIt<CreateTreeUseCase>(),
      ),
      child: child,
    );
  }
}