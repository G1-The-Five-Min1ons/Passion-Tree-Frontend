import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/services/home_tab_navigation_notifier.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/user_profile.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_profile_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:passion_tree_frontend/features/dashboard/domain/usecases/get_dashboard_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_status.dart';
import 'package:passion_tree_frontend/features/mission/data/models/user_mission_model.dart';
import 'package:passion_tree_frontend/features/mission/presentation/bloc/mission_bloc.dart';
import 'package:passion_tree_frontend/features/mission/presentation/bloc/mission_event.dart';
import 'package:passion_tree_frontend/features/mission/presentation/bloc/mission_state.dart';
import 'package:passion_tree_frontend/features/setting/presentation/pages/setting_page.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/profile_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/tree_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/learning_path_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/weekly_mission_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/recent_activity_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/activity_heatmap_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/section_title.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/pages/mission_center_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GetProfileUseCase _getProfileUseCase = getIt<GetProfileUseCase>();
  final GetDashboardUseCase _getDashboardUseCase = getIt<GetDashboardUseCase>();
  final GetLearningPathStatus _getLearningPathStatus =
      getIt<GetLearningPathStatus>();

  bool _isLoading = true;
  UserProfile? _userProfile;
  DashboardResponse? _dashboardData;
  List<EnrolledLearningPath> _enrolledPaths = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Fetch profile, dashboard, and enrolled paths in parallel
      final profileFuture = _getProfileUseCase.execute();
      final dashboardFuture = _getDashboardUseCase.execute();
      final userIdFuture = getIt<IAuthRepository>().getUserId();

      final profileResult = await profileFuture;
      final dashboardResult = await dashboardFuture;
      final userId = await userIdFuture;

      // Fetch enrolled paths using the same API as Learn page
      List<EnrolledLearningPath> enrolledPaths = [];
      if (userId != null && userId.isNotEmpty) {
        try {
          enrolledPaths = await _getLearningPathStatus.call(userId);
        } catch (_) {
          // Fall back to empty list if fetch fails
        }
      }

      if (!mounted) return;

      profileResult.fold((_) {}, (profile) {
        _userProfile = profile;
      });

      setState(() {
        _dashboardData = dashboardResult;
        _enrolledPaths = enrolledPaths;
        _isLoading = false;
      });
    } catch (_) {
      // Ensure the loading spinner clears even if something throws.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    // Refresh missions through the shared MissionBloc — done after the
    // setState so the loading spinner clears regardless of bloc state.
    if (mounted) {
      try {
        context.read<MissionBloc>().add(const FetchMyMissions());
      } catch (_) {
        // ignore — provider may not be available in tests
      }
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void _openLearningSource() {
    HomeTabNavigationNotifier.jumpToTab(1);
  }

  void _openReflectSource() {
    HomeTabNavigationNotifier.jumpToTab(2);
  }

  void _showNotReadyMessage(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: source page is not available yet.')),
    );
  }

  void _onActivityTap(ActivityItem item) {
    switch (item.activityType) {
      case 'enroll_path':
      case 'complete_node':
        _openLearningSource();
        return;
      case 'complete_mission':
        _openLearningSource();
        return;
      case 'reflection':
      case 'create_reflection':
        _openReflectSource();
        return;
      default:
        _showNotReadyMessage(item.typeLabel);
    }
  }

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

  String get _fullName {
    final user = _userProfile?.user;
    if (user == null) return 'Student';

    final fullName = '${user.firstName} ${user.lastName}'.trim();
    return fullName.isEmpty ? user.username : fullName;
  }

  String get _roleLabel {
    final role = _userProfile?.user.role.toLowerCase();
    if (role == 'teacher') return 'Teacher';
    return 'Student';
  }

  _ResolvedProfileStats get _resolvedStats {
    final profile = _userProfile?.profile;
    final userInfo = _dashboardData?.userInfo;

    if (profile != null) {
      return _ResolvedProfileStats(
        level: profile.level,
        xp: profile.xp,
        hours: profile.hourLearned,
        streak: profile.learningStreak,
        learningPathCount: profile.learningCount,
      );
    }

    if (userInfo != null) {
      return _ResolvedProfileStats(
        level: userInfo.level,
        xp: userInfo.xp,
        hours: userInfo.hourLearned,
        streak: userInfo.learningStreak,
        learningPathCount: _dashboardData?.currentPaths.length ?? 0,
      );
    }

    return const _ResolvedProfileStats(
      level: 1,
      xp: 0,
      hours: 0,
      streak: 0,
      learningPathCount: 0,
    );
  }

  double get _xpProgress {
    final xp = _resolvedStats.xp;
    final nextXp = ((xp ~/ 1000) + 1) * 1000;
    return (xp / nextXp).clamp(0, 1);
  }

  int get _level => _resolvedStats.level;
  int get _xp => _resolvedStats.xp;
  int get _nextXp => ((_xp ~/ 1000) + 1) * 1000;
  int get _hours => _resolvedStats.hours;
  int get _streak => _resolvedStats.streak;
  int get _learningPathCount => _enrolledPaths.isNotEmpty
      ? _enrolledPaths.length
      : _resolvedStats.learningPathCount;

  String get _memberSince {
    final createdAt = _userProfile?.user.createdAt;
    if (createdAt == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const AppBarWidget(
        title: 'Dashboard & Profile',
        showBackButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileCardWidget(
                      fullName: _fullName,
                      roleLabel: _roleLabel,
                      email: _userProfile?.user.email ?? 'you@example.com',
                      avatarUrl: _userProfile?.profile?.avatarUrl ?? '',
                      location:
                          (_userProfile?.profile?.location?.isNotEmpty == true)
                          ? _userProfile!.profile!.location!
                          : '',
                      bio: (_userProfile?.profile?.bio?.isNotEmpty == true)
                          ? _userProfile!.profile!.bio!
                          : '',
                      level: _level,
                      xp: _xp,
                      nextXp: _nextXp,
                      xpProgress: _xpProgress,
                      hours: _hours,
                      streak: _streak,
                      learningPathCount: _learningPathCount,
                      memberSince: _memberSince,
                      onSettingsTap: _openSettings,
                    ),
                    const SizedBox(height: 14),
                    const SectionTitle(title: 'My Garden'),
                    const SizedBox(height: 8),
                    TreeCardWidget(
                      level: _level,
                      treeStats: _dashboardData?.treeCounter,
                    ),
                    const SizedBox(height: 14),
                    const SectionTitle(title: 'My Learning Path'),
                    const SizedBox(height: 8),
                    LearningPathCardWidget(enrolledPaths: _enrolledPaths),
                    const SizedBox(height: 14),
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
                          onRetry: () => context
                              .read<MissionBloc>()
                              .add(const FetchMyMissions()),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    const SectionTitle(title: 'Recent Activity'),
                    const SizedBox(height: 8),
                    RecentActivityCardWidget(
                      activities: _dashboardData?.recentActivity ?? [],
                      onActivityTap: _onActivityTap,
                    ),
                    const SizedBox(height: 14),
                    const SectionTitle(title: 'Activity'),
                    const SizedBox(height: 8),
                    ActivityHeatmapWidget(
                      heatmapData: _dashboardData?.activitySummary ?? [],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ResolvedProfileStats {
  const _ResolvedProfileStats({
    required this.level,
    required this.xp,
    required this.hours,
    required this.streak,
    required this.learningPathCount,
  });

  final int level;
  final int xp;
  final int hours;
  final int streak;
  final int learningPathCount;
}
