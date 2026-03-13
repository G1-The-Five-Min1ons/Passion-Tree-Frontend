import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/layout/app_background.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button_white.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/albums_reflection_tree.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/homebar.dart';
import 'package:passion_tree_frontend/features/home/presentation/bloc/home_bloc_provider.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/login_page.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/user_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all dependencies (GetIt)
  await initializeDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<UserBloc>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Passion Tree',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        builder: (context, child) => AppBackground(child: child!),
        home: const AuthGate(),
      ),
    );
  }
}

/// Gates the entire app behind authentication.
/// Checks if a valid token exists — if yes, goes to HomeBarWidget;
/// otherwise shows LoginPage.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: getIt<IAuthRepository>().isLoggedIn(),
      builder: (context, snapshot) {
        // While checking auth status, show a loading screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/tree_icon.png',
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(width: 100, height: 100);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Passion Tree',
                    style: AppPixelTypography.h2.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // If logged in, go to main app
        if (snapshot.data == true) {
          return const HomeBlocProvider(
            child: HomeBarWidget(),
          );
        }

        // Otherwise, require login
        return const LoginPage();
      },
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
            

    
          ],
        ),
      ),
    );
  }
}
