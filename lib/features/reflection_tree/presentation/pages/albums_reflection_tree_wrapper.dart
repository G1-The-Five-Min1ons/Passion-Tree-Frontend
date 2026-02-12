import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc_provider.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/albums_reflection_tree.dart';

class AlbumsReflectionTreeWrapper extends StatelessWidget {
  const AlbumsReflectionTreeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return AlbumBlocProvider(
      child: const ReflectionTreePage(),
    );
  }
}
