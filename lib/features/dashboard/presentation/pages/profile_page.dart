import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/user_profile.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_profile_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:passion_tree_frontend/features/dashboard/domain/usecases/get_dashboard_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_status.dart';
import 'package:passion_tree_frontend/features/setting/presentation/pages/setting_page.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/profile_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/tree_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/learning_path_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/weekly_mission_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/recent_activity_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/activity_heatmap_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/section_title.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GetProfileUseCase _getProfileUseCase = getIt<GetProfileUseCase>();
  final GetDashboardUseCase _getDashboardUseCase = getIt<GetDashboardUseCase>();
  final GetLearningPathStatus _getLearningPathStatus = getIt<GetLearningPathStatus>();

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

    profileResult.fold(
      (_) {},
      (profile) {
        _userProfile = profile;
      },
    );

    setState(() {
      _dashboardData = dashboardResult;
      _enrolledPaths = enrolledPaths;
      _isLoading = false;
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
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

  double get _xpProgress {
    final xp = _userProfile?.profile?.xp ?? _dashboardData?.userInfo.xp ?? 0;
    final nextXp = ((xp ~/ 1000) + 1) * 1000;
    return (xp / nextXp).clamp(0, 1);
  }

  int get _level =>
      _userProfile?.profile?.level ?? _dashboardData?.userInfo.level ?? 1;
  int get _xp =>
      _userProfile?.profile?.xp ?? _dashboardData?.userInfo.xp ?? 0;
  int get _nextXp => ((_xp ~/ 1000) + 1) * 1000;
  int get _hours =>
      _userProfile?.profile?.hourLearned ??
      _dashboardData?.userInfo.hourLearned ??
      0;
  int get _streak =>
      _userProfile?.profile?.learningStreak ??
      _dashboardData?.userInfo.learningStreak ??
      0;
  int get _learningPathCount =>
      _enrolledPaths.isNotEmpty
          ? _enrolledPaths.length
          : _dashboardData?.currentPaths.length ??
            _userProfile?.profile?.learningCount ??
            0;

  String get _rankName {
    final profileRank = _userProfile?.profile?.rankName;
    if (profileRank != null && profileRank.isNotEmpty) return profileRank;
    final dashRank = _dashboardData?.userInfo.rankName;
    if (dashRank != null && dashRank.isNotEmpty) return dashRank;
    return 'Beginner';
  }

  String get _memberSince {
    final createdAt = _userProfile?.user.createdAt;
    if (createdAt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      location:
                          (_userProfile?.profile?.location?.isNotEmpty == true)
                              ? _userProfile!.profile!.location!
                              : '',
                      bio:
                          (_userProfile?.profile?.bio?.isNotEmpty == true)
                              ? _userProfile!.profile!.bio!
                              : '',
                      level: _level,
                      xp: _xp,
                      nextXp: _nextXp,
                      xpProgress: _xpProgress,
                      hours: _hours,
                      streak: _streak,
                      learningPathCount: _learningPathCount,
                      rankName: _rankName,
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
                    LearningPathCardWidget(
                      enrolledPaths: _enrolledPaths,
                    ),
                    const SizedBox(height: 14),
                    WeeklyMissionCardWidget(
                      missions: _dashboardData?.weeklyMissions ?? [],
                    ),
                    const SizedBox(height: 14),
                    const SectionTitle(title: 'Recent Activity'),
                    const SizedBox(height: 8),
                    RecentActivityCardWidget(
                      activities: _dashboardData?.recentActivity ?? [],
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
