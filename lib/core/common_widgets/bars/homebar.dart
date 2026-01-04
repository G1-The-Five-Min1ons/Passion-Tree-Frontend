import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/reflection_tree.dart';

import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class HomeBarWidget extends StatefulWidget {
  const HomeBarWidget({super.key});

  @override
  State<HomeBarWidget> createState() => _HomeBarWidgetState();
}

class _HomeBarWidgetState extends State<HomeBarWidget> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Home',
    'Learn',
    'Reflect',
    'Profile',
  ];

  // ใส่หน้าของตัวเองตรงนี้
  final List<Widget> _pages = [
   const Center(child: Text('Home')),   
    const Center(child: Text('Learn')),   
    const ReflectionTreePage(),
    const Center(child: Text('Profile')), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: _titles[_selectedIndex], showBackButton: false),

      body: _pages[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, 
        backgroundColor: AppColors.bar,
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
          icon: PixelIcon(
            assetPath,
            size: 24,
            color: _selectedIndex == index ? Colors.white : null,
          ),
          label: label,
        );
      }
  }