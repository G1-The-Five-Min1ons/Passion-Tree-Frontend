import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/layout/app_background.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/homebar.dart';
import 'package:passion_tree_frontend/features/home/presentation/bloc/home_bloc_provider.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/login_page.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/user_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/pages/forest_preview_page.dart';

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
        // home: const ForestPreviewPage(),
      ),
    );
  }
}

/// Gates the entire app behind authentication.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, bool>> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasOnboarded = prefs.getBool('hasOnboarded') ?? false;
      final isLoggedIn = await getIt<IAuthRepository>().isLoggedIn();

      return {'hasOnboarded': hasOnboarded, 'isLoggedIn': isLoggedIn};
    } catch (e) {
      // ดักจับ Error กรณี SharedPreferences หรือเซิร์ฟเวอร์มีปัญหา
      debugPrint('AuthGate Initialization Error: $e');
      return {'hasOnboarded': false, 'isLoggedIn': false}; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: _init(),
      builder: (context, snapshot) {
        
        // 1. สถานะกำลังโหลด (Waiting)
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
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Passion Tree',
                    style: AppPixelTypography.h2.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // เพิ่มตัวหมุนโหลดให้ผู้ใช้รู้ว่าแอปกะลังทำงานอยู่
                  const CircularProgressIndicator(color: Colors.white), 
                ],
              ),
            ),
          );
        }

        // 2. สถานะเกิด Error (ป้องกันจอแดง)
        if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'Something went wrong.\nPlease restart the app.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        // 3. สถานะโหลดสำเร็จและมีข้อมูล (Safe Unwrap)
        if (snapshot.hasData) {
          final hasOnboarded = snapshot.data!['hasOnboarded'] ?? false;
          final isLoggedIn = snapshot.data!['isLoggedIn'] ?? false;

          /// STEP 1: onboarding มาก่อนเสมอ
          if (!hasOnboarded) {
            return const OnboardingPage();
          }

          /// STEP 2: เช็ค login
          if (!isLoggedIn) {
            return const LoginPage();
          }

          /// STEP 3: เข้า app
          return const HomeBlocProvider(child: HomeBarWidget());
        }

        // Fallback กรณีฉุกเฉิน
        return const LoginPage();
      },
    );
  }
}