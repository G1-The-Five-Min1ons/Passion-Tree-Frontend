import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';

import 'package:passion_tree_frontend/features/home/presentation/widgets/streak_section.dart';
import 'package:passion_tree_frontend/features/home/presentation/widgets/popular_learning_path.dart';

import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/weekly_mission_card_widget.dart';

import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// cache overview state เพื่อกัน section หายตอน push/pop
  LearningPathOverviewLoaded? _cachedOverview;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userId = await getIt<IAuthRepository>().getUserId();

    if (!mounted) return;

    context.read<LearningPathBloc>().add(FetchLearningPathOverview());
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
                /// STREAK
                const StreakSection(),

                const SizedBox(height: 30),

                /// POPULAR LEARNING PATHS
                BlocBuilder<LearningPathBloc, LearningPathState>(
                  builder: (context, state) {
                    if (state is LearningPathOverviewLoaded) {
                      _cachedOverview = state;
                    }

                    final overview = _cachedOverview;

                    if (overview != null) {
                      final hasEnrolledPaths =
                          overview.enrolledPaths.isNotEmpty;

                      final enrolledPathIds = overview.enrolledPaths
                          .map((e) => e.pathId.trim())
                          .toSet();
                      final unenrolledPaths = overview.allPaths
                          .where(
                            (p) =>
                                p.publishStatus.toLowerCase().trim() ==
                                    'published' &&
                                !enrolledPathIds.contains(p.id.trim()),
                          )
                          .toList();

                      return PopularLearningPathsSection(
                        paths: unenrolledPaths,
                        hasEnrolledPaths: hasEnrolledPaths,
                      );
                    }

                    if (state is LearningPathLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return const SizedBox();
                  },
                ),

                const SizedBox(height: 30),

                /// WEEKLY MISSION (แทน Reflection)
                const WeeklyMissionCardWidget(missions: []),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
