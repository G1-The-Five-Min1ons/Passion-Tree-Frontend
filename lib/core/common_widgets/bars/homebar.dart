import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/services/home_tab_navigation_notifier.dart';
import 'package:passion_tree_frontend/core/services/startup_prefetch_service.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/pages/learning_path_role_entry_page.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/home/presentation/pages/home_wrapper.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/albums_reflection_tree_wrapper.dart';
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

    final startupPrefetchService = getIt<StartupPrefetchService>();
    await startupPrefetchService.runInOrder(
      learningPathBloc: context.read<LearningPathBloc>(),
    );
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
