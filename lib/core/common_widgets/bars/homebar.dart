import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/core/services/home_tab_navigation_notifier.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/dashboard/domain/usecases/get_dashboard_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/pages/learning_path_role_entry_page.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_status.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_usecases.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/home/presentation/pages/home_wrapper.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/usecases/album_usecases.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/albums_reflection_tree_wrapper.dart';
import 'package:passion_tree_frontend/features/setting/domain/usecases/get_settings_usecase.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/pages/profile_page.dart';

class HomeBarWidget extends StatefulWidget {
  const HomeBarWidget({super.key});

  @override
  State<HomeBarWidget> createState() => _HomeBarWidgetState();
}

class _HomeBarWidgetState extends State<HomeBarWidget> {
  int _selectedIndex = 0;
  bool _hasStartedPrefetch = false;

  late final List<Widget> _pages;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeWrapper(),
      _buildTabNavigator(1, const LearningPathRoleEntryPage()),
      _buildTabNavigator(2, const AlbumsReflectionTreeWrapper()),
      _buildTabNavigator(3, const ProfilePage()),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _runStartupPrefetchInOrder();
    });

    HomeTabNavigationNotifier.changes.addListener(_handleExternalTabNavigation);
  }

  @override
  void dispose() {
    HomeTabNavigationNotifier.changes.removeListener(
      _handleExternalTabNavigation,
    );
    super.dispose();
  }

  void _handleExternalTabNavigation() {
    final target = HomeTabNavigationNotifier.consumeTargetTab();
    if (target == null || target < 0 || target >= _pages.length) {
      return;
    }

    _navigatorKeys[target].currentState?.popUntil((route) => route.isFirst);

    if (_selectedIndex == target) return;

    setState(() {
      _selectedIndex = target;
    });
  }

  Future<void> _runStartupPrefetchInOrder() async {
    if (_hasStartedPrefetch) return;
    _hasStartedPrefetch = true;

    final authRepository = getIt<IAuthRepository>();
    final userId = await authRepository.getUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }

    await _prefetchHome(userId);
    await _prefetchLearningPath(userId);
    await _prefetchReflect();
    await _prefetchDashboard();
    await _prefetchSetting();
  }

  Future<void> _prefetchHome(String userId) async {
    try {
      final bloc = context.read<LearningPathBloc>();
      final state = bloc.state;

      if (state is LearningPathOverviewLoaded || state is LearningPathLoading) {
        return;
      }

      bloc.add(FetchLearningPathOverview(userId: userId));

      await bloc.stream.firstWhere(
        (s) => s is LearningPathOverviewLoaded || s is LearningPathError,
      );
    } catch (e) {
      LogHandler.warning('Startup prefetch HOME failed: $e');
    }
  }

  Future<void> _prefetchLearningPath(String userId) async {
    try {
      await getIt<GetAllLearningPaths>().call();
      await getIt<GetLearningPathStatus>().call(userId);
      await getIt<GetRecommendedLearningPaths>().call();
    } catch (e) {
      LogHandler.warning('Startup prefetch LEARNING_PATH failed: $e');
    }
  }

  Future<void> _prefetchReflect() async {
    try {
      final result = await getIt<GetAlbumsByUserIdUseCase>().call();
      result.fold(
        (failure) => LogHandler.warning(
          'Startup prefetch REFLECT failed: ${failure.message}',
        ),
        (_) {},
      );
    } catch (e) {
      LogHandler.warning('Startup prefetch REFLECT failed: $e');
    }
  }

  Future<void> _prefetchDashboard() async {
    try {
      await getIt<GetDashboardUseCase>().execute();
    } catch (e) {
      LogHandler.warning('Startup prefetch DASHBOARD failed: $e');
    }
  }

  Future<void> _prefetchSetting() async {
    try {
      await getIt<GetSettingsUseCase>().execute();
    } catch (e) {
      LogHandler.warning('Startup prefetch SETTING failed: $e');
    }
  }

  Widget _buildTabNavigator(int index, Widget rootPage) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => rootPage);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.homeBarColor,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor: AppColors.iconbar,

        selectedLabelStyle: AppPixelTypography.littleSmall,
        unselectedLabelStyle: AppPixelTypography.littleSmall,

        items: [
          _buildNavItem('Home', 'assets/icons/Home.png', 0),
          _buildNavItem('Learn', 'assets/icons/Learn.png', 1),
          _buildNavItem('Reflect', 'assets/icons/Reflect.png', 2),
          _buildNavItem('Profile', 'assets/icons/Profile.png', 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    String label,
    String assetPath,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: PixelIcon(
          assetPath,
          size: 24,
          color: _selectedIndex == index ? Colors.white : null,
        ),
      ),
      label: label,
    );
  }
}
