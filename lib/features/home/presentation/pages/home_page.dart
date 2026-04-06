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
import 'package:passion_tree_frontend/features/dashboard/presentation/pages/mission_center_page.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/mock/mock_missions.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';

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
  bool _hasRequestedInitialLoad = false;
  late final List<MissionItem> _homeMissions;

  @override
  void initState() {
    super.initState();
    _homeMissions = buildMockWeeklyMissions();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadData();
    });
  }

  void _openMissionCenter({MissionItem? highlightedMission}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MissionCenterPage(
          missions: _homeMissions,
          highlightedMissionId: highlightedMission?.missionId,
        ),
      ),
    );
  }

  void _onMissionTap(MissionItem mission) {
    _openMissionCenter(highlightedMission: mission);
  }

  Future<void> _loadData() async {
    if (_hasRequestedInitialLoad) return;

    final currentState = context.read<LearningPathBloc>().state;
    if (currentState is LearningPathOverviewLoaded ||
        currentState is LearningPathLoading) {
      return;
    }

    final userId = await getIt<IAuthRepository>().getUserId();

    if (!mounted) return;

    if (userId == null || userId.isEmpty) {
      _clearCachedOverview();
      _hasRequestedInitialLoad = false;
      return;
    }

    _hasRequestedInitialLoad = true;

    context.read<LearningPathBloc>().add(
      FetchLearningPathOverview(userId: userId),
    );
  }

  void _clearCachedOverview() {
    if (!mounted || _cachedOverview == null) return;
    setState(() {
      _cachedOverview = null;
    });
  }

  void _handleOverviewState(LearningPathState state) {
    if (state is LearningPathOverviewLoaded && mounted) {
      setState(() {
        _cachedOverview = state;
      });
      return;
    }

    if (state is LearningPathError) {
      _clearCachedOverview();
      _hasRequestedInitialLoad = false;
    }
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
                BlocListener<LearningPathBloc, LearningPathState>(
                  listener: (context, state) => _handleOverviewState(state),
                  child: BlocBuilder<LearningPathBloc, LearningPathState>(
                    builder: (context, state) {
                      final overview = _cachedOverview;

                      if (overview != null) {
                        final hasEnrolledPaths =
                            overview.enrolledPaths.isNotEmpty;
                        final hasRecommendedPaths =
                            overview.recommendedPaths.isNotEmpty;
                        final displayRecommended =
                            hasEnrolledPaths && hasRecommendedPaths;
                        final displayPaths = displayRecommended
                            ? overview.recommendedPaths
                            : overview.allPaths;

                        return PopularLearningPathsSection(
                          paths: displayPaths,
                          hasEnrolledPaths: displayRecommended,
                        );
                      }

                      if (state is LearningPathLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return const SizedBox();
                    },
                  ),
                ),

                const SizedBox(height: 30),

                /// WEEKLY MISSION (แทน Reflection)
                WeeklyMissionCardWidget(
                  missions: _homeMissions,
                  onMissionTap: _onMissionTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
