import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/services/home_tab_navigation_notifier.dart';
import 'package:passion_tree_frontend/core/services/startup_prefetch_service.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/home/presentation/pages/home_wrapper.dart';
import 'package:passion_tree_frontend/features/home/presentation/pages/main_tab_bootstrap_pages.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/homebar_visibility.dart';

class HomeBarWidget extends StatefulWidget {
  final bool enableStartupPrefetch;

  const HomeBarWidget({super.key, this.enableStartupPrefetch = true});

  @override
  State<HomeBarWidget> createState() => _HomeBarWidgetState();
}

class _HomeBarWidgetState extends State<HomeBarWidget> {
  static const int _tabCount = 4;

  int _selectedIndex = 0;
  bool _hasStartedPrefetch = false;
  late final List<Widget?> _pageCache;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // ใส่หน้าของตัวเองตรงนี้

  @override
  void initState() {
    super.initState();
    _pageCache = List<Widget?>.filled(_tabCount, null, growable: false);
    _ensurePageInitialized(0);

    if (widget.enableStartupPrefetch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _runStartupPrefetchInOrder();
      });
    }

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
    if (target == null || target < 0 || target >= _tabCount) {
      return;
    }

    _ensurePageInitialized(target);

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
      albumBloc: context.read<AlbumBloc>(),
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

  void _ensurePageInitialized(int index) {
    if (_pageCache[index] != null) return;

    switch (index) {
      case 0:
        _pageCache[index] = HomeWrapper(
          enableStartupPrefetch: widget.enableStartupPrefetch,
          navigatorKey: _navigatorKeys[0],
        );
        break;
      case 1:
        _pageCache[index] = _buildTabNavigator(
          1,
          const LearnTabBootstrapPage(),
        );
        break;
      case 2:
        _pageCache[index] = _buildTabNavigator(
          2,
          const ReflectTabBootstrapPage(),
        );
        break;
      case 3:
        _pageCache[index] = _buildTabNavigator(
          3,
          const ProfileTabBootstrapPage(),
        );
        break;
    }
  }

  void _setSelectedIndex(int index) {
    if (index < 0 || index >= _tabCount) {
      return;
    }

    _ensurePageInitialized(index);

    // Tapping the currently active tab pops its inner navigator back to its root.
    if (_selectedIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    // popped back to its root so the user always lands on the first page
  
    _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);

    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _handleSystemBack() async {
    final navigator = _navigatorKeys[_selectedIndex].currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return false; // Consumed — keep app in foreground.
    }

    // If we're not on the Home tab, jump back to it instead of exiting.
    if (_selectedIndex != 0) {
      _ensurePageInitialized(0);
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }

    return true; // Allow the system to background the app.
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _handleSystemBack();
        if (shouldExit) {
          // Send the app to the background instead of force-closing it,
          // mirroring native Android behavior when the back stack is empty.
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: List<Widget>.generate(
            _tabCount,
            (index) => _pageCache[index] ?? const SizedBox.shrink(),
          ),
        ),
        bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: homeBarVisibilityNotifier,
          builder: (context, isVisible, _) {
            if (!isVisible) {
              return const SizedBox.shrink();
            }

            return BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                _setSelectedIndex(index);
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
            );
          },
        ),
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
