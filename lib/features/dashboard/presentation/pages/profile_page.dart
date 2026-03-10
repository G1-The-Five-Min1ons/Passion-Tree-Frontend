import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/user_profile.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_profile_usecase.dart';
import 'package:passion_tree_frontend/features/setting/presentation/pages/setting_page.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/profile_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/tree_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/learning_path_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/weekly_mission_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/recent_activity_card_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/activity_heatmap_widget.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/dashboard_footer.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/section_title.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GetProfileUseCase _getProfileUseCase = getIt<GetProfileUseCase>();

  bool _isLoading = true;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final result = await _getProfileUseCase.execute();

    if (!mounted) return;

    result.fold((_) => setState(() => _isLoading = false), (profile) {
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
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
    if (user == null) return 'Passion Gardener';

    final fullName = '${user.firstName} ${user.lastName}'.trim();
    return fullName.isEmpty ? user.username : fullName;
  }

  String get _roleLabel {
    final role = _userProfile?.user.role.toLowerCase();
    if (role == 'teacher') return 'Teacher';
    return 'Passion Gardener';
  }

  double get _xpProgress {
    final xp = _userProfile?.profile?.xp ?? 500;
    final nextXp = ((xp ~/ 1000) + 1) * 1000;
    return (xp / nextXp).clamp(0, 1);
  }

  int get _level => _userProfile?.profile?.level ?? 15;
  int get _xp => _userProfile?.profile?.xp ?? 500;
  int get _nextXp => ((_xp ~/ 1000) + 1) * 1000;
  int get _hours => _userProfile?.profile?.hourLearned ?? 120;
  int get _streak => _userProfile?.profile?.learningStreak ?? 17;
  int get _learningPathCount => _userProfile?.profile?.learningCount ?? 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarWidget(
        title: 'Dashboard&Profile',
        showBackButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileCardWidget(
                    fullName: _fullName,
                    roleLabel: _roleLabel,
                    email: _userProfile?.user.email ?? 'you@example.com',
                    location:
                        _userProfile?.profile?.location ?? 'Bangkok, Thailand',
                    bio:
                        _userProfile?.profile?.bio ??
                        'Passionate about creating digital experiences and learning new technologies.',
                    level: _level,
                    xp: _xp,
                    nextXp: _nextXp,
                    xpProgress: _xpProgress,
                    hours: _hours,
                    streak: _streak,
                    learningPathCount: _learningPathCount,
                    onSettingsTap: _openSettings,
                  ),
                  const SizedBox(height: 12),
                  TreeCardWidget(level: _level),
                  const SizedBox(height: 18),
                  const SectionTitle(title: 'My Learning Path'),
                  const SizedBox(height: 10),
                  const LearningPathCardWidget(),
                  const SizedBox(height: 16),
                  const WeeklyMissionCardWidget(),
                  const SizedBox(height: 16),
                  const SectionTitle(title: 'Recent Activity'),
                  const SizedBox(height: 10),
                  const RecentActivityCardWidget(),
                  const SizedBox(height: 16),
                  const SectionTitle(title: 'Activity'),
                  const SizedBox(height: 10),
                  const ActivityHeatmapWidget(),
                  const SizedBox(height: 16),
                  const DashboardFooter(),
                ],
              ),
            ),
    );
  }
}
