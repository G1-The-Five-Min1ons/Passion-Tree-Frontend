import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/services/main_tabs_prefetch_cache.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/user_profile.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_profile_usecase.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:passion_tree_frontend/features/dashboard/domain/usecases/get_dashboard_usecase.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/pages/profile_page.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_status.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/pages/learning_path_role_entry_page.dart';
import 'package:passion_tree_frontend/features/mission/presentation/bloc/mission_bloc.dart';
import 'package:passion_tree_frontend/features/mission/presentation/bloc/mission_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/albums_reflection_tree_wrapper.dart';
import 'package:passion_tree_frontend/features/setting/domain/usecases/get_settings_usecase.dart';

class LearnTabBootstrapPage extends StatefulWidget {
  const LearnTabBootstrapPage({super.key});

  @override
  State<LearnTabBootstrapPage> createState() => _LearnTabBootstrapPageState();
}

class _LearnTabBootstrapPageState extends State<LearnTabBootstrapPage> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<LearningPathBloc>().state;
    if (state is LearningPathOverviewLoaded || state is LearningPathError) {
      _ready = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final bloc = context.read<LearningPathBloc>();

    while (mounted) {
      final state = bloc.state;
      if (state is LearningPathOverviewLoaded) {
        break;
      }

      if (state is! LearningPathLoading) {
        bloc.add(FetchLearningPathOverview());
      }

      try {
        await bloc.stream.firstWhere(
          (s) => s is LearningPathOverviewLoaded || s is LearningPathError,
        );
      } catch (_) {
        // Keep waiting and retrying until loaded.
      }

      if (!mounted) return;
      if (bloc.state is! LearningPathOverviewLoaded) {
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }
    }

    if (!mounted) return;
    setState(() {
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return const LearningPathRoleEntryPage();
    }

    return const _MainTabLoadingView();
  }
}

class ReflectTabBootstrapPage extends StatefulWidget {
  const ReflectTabBootstrapPage({super.key});

  @override
  State<ReflectTabBootstrapPage> createState() =>
      _ReflectTabBootstrapPageState();
}

class _ReflectTabBootstrapPageState extends State<ReflectTabBootstrapPage> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AlbumBloc>().state;
    if (state is AlbumsLoaded || state is AlbumError) {
      _ready = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final bloc = context.read<AlbumBloc>();

    while (mounted) {
      final state = bloc.state;
      if (state is AlbumsLoaded) {
        break;
      }

      if (state is! AlbumLoading) {
        bloc.add(const LoadAlbumsEvent());
      }

      try {
        await bloc.stream.firstWhere(
          (s) => s is AlbumsLoaded || s is AlbumError,
        );
      } catch (_) {
        // Keep waiting and retrying until loaded.
      }

      if (!mounted) return;
      if (bloc.state is! AlbumsLoaded) {
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }
    }

    if (!mounted) return;
    setState(() {
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return const AlbumsReflectionTreeWrapper(enableStartupPrefetch: false);
    }

    return const _MainTabLoadingView();
  }
}

class ProfileTabBootstrapPage extends StatefulWidget {
  const ProfileTabBootstrapPage({super.key});

  @override
  State<ProfileTabBootstrapPage> createState() =>
      _ProfileTabBootstrapPageState();
}

class _ProfileTabBootstrapPageState extends State<ProfileTabBootstrapPage> {
  bool _ready = false;
  UserProfile? _userProfile;
  DashboardResponse? _dashboardData;
  List<EnrolledLearningPath> _enrolledPaths = const [];

  @override
  void initState() {
    super.initState();

    final cache = MainTabsPrefetchCache.instance;
    if (cache.hasProfilePayload) {
      _userProfile = cache.userProfile;
      _dashboardData = cache.dashboardData;
      _enrolledPaths = cache.enrolledPaths;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _bootstrapSettingsOnly();
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    while (mounted) {
      var loaded = false;

      try {
        final getProfile = getIt<GetProfileUseCase>();
        final getDashboard = getIt<GetDashboardUseCase>();
        final getStatus = getIt<GetLearningPathStatus>();
        final getSettings = getIt<GetSettingsUseCase>();
        final authRepository = getIt<IAuthRepository>();

        final profileResult = await getProfile.execute();
        final dashboardResult = await getDashboard.execute();
        final settingsResult = await getSettings.execute();
        final userId = await authRepository.getUserId();

        final profile = profileResult.fold<UserProfile?>((_) => null, (p) => p);
        final settingsLoaded = settingsResult.isRight();
        final dashboardLoaded = dashboardResult != null;

        if (profile != null && settingsLoaded && dashboardLoaded) {
          _userProfile = profile;
          _dashboardData = dashboardResult;

          if (userId != null && userId.isNotEmpty) {
            _enrolledPaths = await getStatus.call(userId);
          } else {
            _enrolledPaths = const [];
          }

          if (!mounted) return;
          try {
            context.read<MissionBloc>().add(const FetchMyMissions());
          } catch (_) {
            // ignore
          }

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

  Future<void> _bootstrapSettingsOnly() async {
    while (mounted) {
      var loaded = false;
      try {
        final getSettings = getIt<GetSettingsUseCase>();
        final settingsResult = await getSettings.execute();
        loaded = settingsResult.isRight();
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
      return ProfilePage(
        enableStartupPrefetch: false,
        initialUserProfile: _userProfile,
        initialDashboardData: _dashboardData,
        initialEnrolledPaths: _enrolledPaths,
      );
    }

    return const _MainTabLoadingView();
  }
}

class _MainTabLoadingView extends StatelessWidget {
  const _MainTabLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/tree_icon.png', width: 88, height: 88),
            const SizedBox(height: 20),
            Text(
              'Passion Tree',
              style: AppPixelTypography.h2.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
