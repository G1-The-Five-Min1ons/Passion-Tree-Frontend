import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button_white.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/pages/learning_path_overview_page.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/reflection_tree.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/album.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/login_page.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/dev_home_selector_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const DevHomeSelectorPage(), // DEV: Home selector for frontend
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: "Learning Path",
        showBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('TEST', style: Theme.of(context).textTheme.displaySmall),
            Text('button:', style: AppPixelTypography.title),
            const Text('You have pushed the button this many times:'),
            Text(
              'TEST',
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 20,
              ),
            ),

            // ===== Pixel Button =====
            //text only 
            AppButton(
              variant: AppButtonVariant.text,
              text: 'Text',
              onPressed: () {
                debugPrint('Submit pressed');
              },
            ),

            //textWithIcon
            AppButton(
              variant: AppButtonVariant.textWithIcon,
              text: 'Like',
              icon: const PixelIcon('assets/icons/Pixel_heart.png'),
              onPressed: () {},
            ),

            //icon only
            AppButton(
              variant: AppButtonVariant.iconOnly,
              icon: const PixelIcon('assets/icons/Pixel_plus.png', size: 16),
              onPressed: () {},
            ),

            // ===== Navigation Button =====
            NavigationButton(
                  direction: NavigationDirection.right,
                  onPressed: () {
                    debugPrint('Right pressed');
                  },
                ),
            // ===== White Navigation Button =====
            NavigationButtonWhite(
                  direction: NavigationDirection.left,
                  onPressed: () {
                    debugPrint('Left pressed');
                  },
                ),
            // ===== ปุ่มไปหน้า Reflection =====
            AppButton(
              variant: AppButtonVariant.text,
              text: 'Go to Reflection',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReflectionTreePage(),
                  ),
                );
              },
            ),
            PixelAlbumCover(
            size: 150,
            imageUrl: 'https://images.theconversation.com/files/45159/original/rptgtpxd-1396254731.jpg?ixlib=rb-4.1.0&q=45&auto=format&w=1356&h=668&fit=crop',
            title: 'Science',
            subtitle: 'Edited 10 minutes ago',
            ),

            // ===== ปุ่มไปหน้า Learning Path =====
            AppButton(
              variant: AppButtonVariant.text,
              text: 'Go to Learning Path',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LearningPathOverviewPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
