import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/albums_reflection_tree.dart';

class AlbumsReflectionTreeWrapper extends StatelessWidget {
  final bool enableStartupPrefetch;

  const AlbumsReflectionTreeWrapper({
    super.key,
    this.enableStartupPrefetch = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AlbumBloc>(),
      child: ReflectionTreePage(enableStartupPrefetch: enableStartupPrefetch),
    );
  }
}
