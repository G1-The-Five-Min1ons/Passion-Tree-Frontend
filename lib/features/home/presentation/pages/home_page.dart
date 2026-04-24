import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';

import 'package:passion_tree_frontend/features/home/presentation/widgets/streak_section.dart';
import 'package:passion_tree_frontend/features/home/presentation/widgets/popular_learning_path.dart';

import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/weekly_mission_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:passion_tree_frontend/features/dashboard/domain/usecases/get_dashboard_usecase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// cache overview state เพื่อกัน section หายตอน push/pop
  LearningPathOverviewLoaded? _cachedOverview;

  /// Dashboard data (contains streak, missions, etc.)
  DashboardResponse? _dashboardData;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    context.read<LearningPathBloc>().add(FetchLearningPathOverview());

    // Fetch dashboard data for streak
    try {
      final dashboardUseCase = getIt<GetDashboardUseCase>();
      final data = await dashboardUseCase.execute();
      if (mounted) {
        setState(() {
          _dashboardData = data;
        });
      }
    } catch (_) {
      // Silently fail — streak will show 0
    }
  }

  int get _streakCount =>
      _dashboardData?.userInfo.learningStreak ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Home', showBackButton: false),

      body: SafeArea(
        child: BlocListener<LearningPathBloc, LearningPathState>(
          listener: (context, state) {
            if (state is PathEnrolled) {
              context.read<LearningPathBloc>().add(FetchLearningPathOverview());
            }
          },
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
                  StreakSection(streakCount: _streakCount),

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
                          isLoading: state is LearningPathLoading,
                        );
                      }

                      if (state is LearningPathLoading) {
                        return const PopularLearningPathsSection(
                          paths: [],
                          hasEnrolledPaths: false,
                          isLoading: true,
                        );
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
      ),
    );
  }
}
