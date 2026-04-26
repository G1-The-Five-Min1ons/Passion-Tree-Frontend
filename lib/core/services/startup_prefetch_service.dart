import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/dashboard/domain/usecases/get_dashboard_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';
import 'package:passion_tree_frontend/features/setting/domain/usecases/get_settings_usecase.dart';

class StartupPrefetchService {
  StartupPrefetchService({
    required IAuthRepository authRepository,
    required GetDashboardUseCase getDashboardUseCase,
    required GetSettingsUseCase getSettingsUseCase,
  }) : _authRepository = authRepository,
       _getDashboardUseCase = getDashboardUseCase,
       _getSettingsUseCase = getSettingsUseCase;

  final IAuthRepository _authRepository;
  final GetDashboardUseCase _getDashboardUseCase;
  final GetSettingsUseCase _getSettingsUseCase;

  Future<void> runInOrder({
    required LearningPathBloc learningPathBloc,
    required AlbumBloc albumBloc,
  }) async {
    final userId = await _authRepository.getUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }

    await _prefetchHome(learningPathBloc);
    await _prefetchReflect(albumBloc);
    await _prefetchDashboard();
    await _prefetchSetting();
  }

  Future<void> _prefetchHome(LearningPathBloc learningPathBloc) async {
    try {
      final state = learningPathBloc.state;

      if (state is LearningPathOverviewLoaded || state is LearningPathLoading) {
        return;
      }

      learningPathBloc.add(FetchLearningPathOverview());

      await learningPathBloc.stream.firstWhere(
        (s) => s is LearningPathOverviewLoaded || s is LearningPathError,
      );
    } catch (e) {
      LogHandler.warning('Startup prefetch HOME failed: $e');
    }
  }

  Future<void> _prefetchReflect(AlbumBloc albumBloc) async {
    try {
      final state = albumBloc.state;
      if (state is AlbumsLoaded || state is AlbumLoading) return;

      albumBloc.add(const LoadAlbumsEvent());

      await albumBloc.stream.firstWhere(
        (s) => s is AlbumsLoaded || s is AlbumError,
      );
    } catch (e) {
      LogHandler.warning('Startup prefetch REFLECT failed: $e');
    }
  }

  Future<void> _prefetchDashboard() async {
    try {
      await _getDashboardUseCase.execute();
    } catch (e) {
      LogHandler.warning('Startup prefetch DASHBOARD failed: $e');
    }
  }

  Future<void> _prefetchSetting() async {
    try {
      await _getSettingsUseCase.execute();
    } catch (e) {
      LogHandler.warning('Startup prefetch SETTING failed: $e');
    }
  }
}
