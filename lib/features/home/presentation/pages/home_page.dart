import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';

import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';

import 'package:passion_tree_frontend/features/home/presentation/widgets/popular_learning_paths.dart';
import 'package:passion_tree_frontend/features/home/presentation/widgets/continue_learning.dart';
import 'package:passion_tree_frontend/features/home/presentation/widgets/continue_reflection.dart';

import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // ดึง userId จาก auth repository
    final userId = await getIt<IAuthRepository>().getUserId();

    if (!mounted) return;

    /// โหลด learning paths พร้อม userId เพื่อดึง enrolledPaths
    context.read<LearningPathBloc>().add(
      FetchLearningPathOverview(userId: userId),
    );

    /// โหลด reflection albums
    context.read<AlbumBloc>().add(const LoadAlbumsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Home', showBackButton: false),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xmargin,
              right: AppSpacing.xmargin,
              top: AppSpacing.ymargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// POPULAR COURSES
                BlocBuilder<LearningPathBloc, LearningPathState>(
                  builder: (context, state) {
                    if (state is LearningPathLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is LearningPathOverviewLoaded) {
                      return PopularLearningPathsSection(paths: state.allPaths);
                    }

                    return const SizedBox();
                  },
                ),

                const SizedBox(height: 60),

                /// CONTINUE LEARNING
                BlocBuilder<LearningPathBloc, LearningPathState>(
                  builder: (context, state) {
                    if (state is LearningPathOverviewLoaded) {
                      return ContinueLearningSection(
                        enrolledPaths: state.enrolledPaths,
                      );
                    }

                    return const SizedBox();
                  },
                ),

                const SizedBox(height: 60),

                /// CONTINUE REFLECTION
                BlocBuilder<AlbumBloc, AlbumState>(
                  builder: (context, state) {
                    if (state is AlbumLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is AlbumsLoaded) {
                      return ContinueReflectionSection(albums: state.albums);
                    }

                    return const SizedBox();
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
