import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:passion_tree_frontend/core/di/injection.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';

class HomeBlocProvider extends StatelessWidget {
  final Widget child;

  const HomeBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        /// Learning Path
        BlocProvider<LearningPathBloc>(
          create: (_) => getIt<LearningPathBloc>(),
        ),

        /// Reflection Album
        BlocProvider<AlbumBloc>(create: (_) => getIt<AlbumBloc>()),
      ],
      child: child,
    );
  }
}
