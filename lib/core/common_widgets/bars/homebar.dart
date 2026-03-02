import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_overview_page.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc_provider.dart';
import 'package:passion_tree_frontend/features/home/presentation/pages/home_page.dart';
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

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
  GlobalKey<NavigatorState>(),
  GlobalKey<NavigatorState>(),
  GlobalKey<NavigatorState>(),
  GlobalKey<NavigatorState>(),
];

  // ใส่หน้าของตัวเองตรงนี้
  late final List<Widget> _pages = [
    _buildTabNavigator(0, const HomePage()),
    _buildTabNavigator(1, const LearningPathBlocProvider(child: LearningPathOverviewPage())),
    _buildTabNavigator(2, const AlbumsReflectionTreeWrapper()),
    _buildTabNavigator(3, const ProfilePage()),
  ];

  Widget _buildTabNavigator(int index, Widget rootPage) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => rootPage,
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
      index: _selectedIndex,
      children: _pages,
    ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, 
        backgroundColor: AppColors.homeBarColor,
        selectedItemColor:  Theme.of(context).colorScheme.onPrimary,
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

      BottomNavigationBarItem _buildNavItem(String label, String assetPath, int index) {
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