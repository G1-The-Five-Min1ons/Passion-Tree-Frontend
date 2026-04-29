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
import 'package:passion_tree_frontend/features/dashboard/presentation/pages/mission_center_page.dart';

import 'package:passion_tree_frontend/features/mission/data/models/user_mission_model.dart';
import 'package:passion_tree_frontend/features/mission/presentation/bloc/mission_bloc.dart';
import 'package:passion_tree_frontend/features/mission/presentation/bloc/mission_event.dart';
import 'package:passion_tree_frontend/features/mission/presentation/bloc/mission_state.dart';

class HomePage extends StatefulWidget {
  final bool enableStartupPrefetch;

  const HomePage({super.key, this.enableStartupPrefetch = true});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// cache overview state เพื่อกัน section หายตอน push/pop
  LearningPathOverviewLoaded? _cachedOverview;

  /// Dashboard data (contains streak)
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

    // Learning paths — skip if data is already loaded or a fetch is in progress
    try {
      final lpBloc = context.read<LearningPathBloc>();
      if (lpBloc.state is! LearningPathOverviewLoaded &&
          lpBloc.state is! LearningPathLoading) {
        lpBloc.add(FetchLearningPathOverview());
      }
    } catch (_) {
      // ignore — provider may not be available in tests
    }

    // Missions are auto-fetched by MissionBlocProvider on first mount.
    // Re-trigger here only if we don't have data yet (e.g., the previous
    // fetch failed). This is a no-op when the bloc is already loaded.
    try {
      final missionBloc = context.read<MissionBloc>();
      if (missionBloc.state is! MissionLoaded) {
        missionBloc.add(const FetchMyMissions());
      }
    } catch (_) {
      // ignore — provider may not be available in tests
    }

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

  int get _streakCount => _dashboardData?.resolvedLearningStreak ?? 0;

  void _onMissionTap(UserMissionModel mission) {
    final state = context.read<MissionBloc>().state;
    final List<UserMissionModel> missions;
    if (state is MissionLoaded) {
      missions = state.missions;
    } else if (state is MissionError) {
      missions = state.previousMissions;
    } else {
      missions = const [];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MissionCenterPage(
          missions: missions,
          highlightedMissionId: mission.missionId,
        ),
      ),
    );
  }

  void _openMissionCenter() {
    final state = context.read<MissionBloc>().state;
    final List<UserMissionModel> missions;
    if (state is MissionLoaded) {
      missions = state.missions;
    } else if (state is MissionError) {
      missions = state.previousMissions;
    } else {
      missions = const [];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MissionCenterPage(missions: missions),
      ),
    );
  }

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
                          isLoading: false,
                        );
                      }

                      return const SizedBox();
                    },
                  ),

                  const SizedBox(height: 30),

                  /// WEEKLY MISSION (real backend via MissionBloc)
                  BlocBuilder<MissionBloc, MissionState>(
                    builder: (context, state) {
                      final List<UserMissionModel> missions;
                      final bool isLoading;
                      String? errorMessage;

                      if (state is MissionLoaded) {
                        missions = state.missions;
                        isLoading = false;
                      } else if (state is MissionError) {
                        missions = state.previousMissions;
                        isLoading = false;
                        errorMessage = state.message;
                      } else if (state is MissionLoading) {
                        missions = const [];
                        isLoading = true;
                      } else {
                        missions = const [];
                        isLoading = false;
                      }

                      return WeeklyMissionCardWidget(
                        missions: missions,
                        isLoading: isLoading,
                        errorMessage: errorMessage,
                        onMissionTap: _onMissionTap,
                        onEmptyTap: _openMissionCenter,
                        onRetry: () => context.read<MissionBloc>().add(
                          const FetchMyMissions(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
