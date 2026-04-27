import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/homebar.dart';
import 'package:passion_tree_frontend/core/common_widgets/layout/app_background.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/services/main_tabs_prefetch_cache.dart';
import 'package:passion_tree_frontend/core/services/startup_prefetch_service.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_profile_usecase.dart';
import 'package:passion_tree_frontend/features/dashboard/domain/usecases/get_dashboard_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_status.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';
import 'package:passion_tree_frontend/features/setting/domain/usecases/get_settings_usecase.dart';

class PostLoginBootstrapPage extends StatefulWidget {
  const PostLoginBootstrapPage({super.key});

  @override
  State<PostLoginBootstrapPage> createState() => _PostLoginBootstrapPageState();
}

class _PostLoginBootstrapPageState extends State<PostLoginBootstrapPage> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    MainTabsPrefetchCache.instance.clear();

    final learningPathBloc = context.read<LearningPathBloc>();
    final albumBloc = context.read<AlbumBloc>();

    while (mounted) {
      var loaded = false;

      try {
        final service = getIt<StartupPrefetchService>();
        final getProfile = getIt<GetProfileUseCase>();
        final getDashboard = getIt<GetDashboardUseCase>();
        final getSettings = getIt<GetSettingsUseCase>();
        final getLearningPathStatus = getIt<GetLearningPathStatus>();
        final authRepository = getIt<IAuthRepository>();

        await service.runInOrder(
          learningPathBloc: learningPathBloc,
          albumBloc: albumBloc,
        );

        final profileResult = await getProfile.execute();
        final dashboardResult = await getDashboard.execute();
        final settingsResult = await getSettings.execute();
        final userId = await authRepository.getUserId();

        final profile = profileResult.fold((_) => null, (data) => data);
        final learningPathLoaded =
            learningPathBloc.state is LearningPathOverviewLoaded;
        final reflectLoaded = albumBloc.state is AlbumsLoaded;
        final profileLoaded = profile != null;
        final dashboardLoaded = dashboardResult != null;
        final settingsLoaded = settingsResult.isRight();

        if (learningPathLoaded &&
            reflectLoaded &&
            profileLoaded &&
            dashboardLoaded &&
            settingsLoaded) {
          List<EnrolledLearningPath> enrolledPaths =
              const <EnrolledLearningPath>[];
          if (userId != null && userId.isNotEmpty) {
            enrolledPaths = await getLearningPathStatus.call(userId);
          }

          MainTabsPrefetchCache.instance.setProfilePayload(
            userProfile: profile,
            dashboardData: dashboardResult,
            enrolledPaths: enrolledPaths,
          );
          loaded = true;
        }
      } catch (_) {
        loaded = false;
      }

      if (loaded) {
        break;
      }

      await Future<void>.delayed(const Duration(milliseconds: 800));
    }

    if (!mounted) return;
    setState(() {
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return const HomeBarWidget(enableStartupPrefetch: false);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: Center(
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
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
