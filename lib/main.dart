import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/layout/app_background.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/services/session_expiry_notifier.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/homebar.dart';
import 'package:passion_tree_frontend/features/home/presentation/bloc/home_bloc_provider.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/login_page.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/user_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all dependencies (GetIt)
  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SessionExpiryNotifier.changes.addListener(_handleSessionExpired);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SessionExpiryNotifier.changes.removeListener(_handleSessionExpired);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _validateSessionOnResume();
    }
  }

  Future<void> _validateSessionOnResume() async {
    final isLoggedIn = await getIt<IAuthRepository>().isLoggedIn();
    if (!mounted || isLoggedIn) return;

    _handleSessionExpired();
  }

  void _handleSessionExpired() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    // ป้องกันการเด้งไปหน้า Login ซ้ำถ้าเราอยู่ที่นั่นอยู่แล้ว
    // (ใช้ชื่อ Route ตามที่เพื่อนตั้งไว้ใน AppRouter)
    bool isAlreadyOnLogin = false;
    navigator.popUntil((route) {
      if (route.settings.name == '/login') {
        isAlreadyOnLogin = true;
      }
      return true;
    });

    if (isAlreadyOnLogin) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/login'),
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );

    // แจ้งผู้ใช้หลังเปลี่ยนหน้าเสร็จ เพื่อไม่ให้ SnackBar หายระหว่างการนำทาง
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _navigatorKey.currentContext;
      if (context == null) return;

      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('เซสชันหมดอายุแล้ว กรุณาเข้าสู่ระบบอีกครั้ง'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<UserBloc>(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Passion Tree',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        builder: (context, child) => AppBackground(child: child!),
        home: const HomeBlocProvider(child: AuthGate()),
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
          return const HomeBarWidget();
        }

        // Fallback กรณีฉุกเฉิน
        return const LoginPage();
      },
    );
  }
}
