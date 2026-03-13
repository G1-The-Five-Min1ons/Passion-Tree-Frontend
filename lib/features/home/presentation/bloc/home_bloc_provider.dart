import 'package:flutter/material.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc_provider.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc_provider.dart';

class HomeBlocProvider extends StatelessWidget {
  final Widget child;

  const HomeBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LearningPathBlocProvider(
      child: AlbumBlocProvider(
        child: child,
      ),
    );
  }
}
