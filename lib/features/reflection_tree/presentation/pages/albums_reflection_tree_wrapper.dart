import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc_provider.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/albums_reflection_tree.dart';

class AlbumsReflectionTreeWrapper extends StatelessWidget {
  final bool enableStartupPrefetch;

  const AlbumsReflectionTreeWrapper({
    super.key,
    this.enableStartupPrefetch = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlbumBlocProvider(
      child: ReflectionTreePage(enableStartupPrefetch: enableStartupPrefetch),
    );
  }
}
