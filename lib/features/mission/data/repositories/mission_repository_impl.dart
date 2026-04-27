import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/mission/data/datasources/mission_remote_data_source.dart';
import 'package:passion_tree_frontend/features/mission/data/models/user_mission_model.dart';
import 'package:passion_tree_frontend/features/mission/domain/repositories/i_mission_repository.dart';

class MissionRepositoryImpl implements IMissionRepository {
  final MissionRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  MissionRepositoryImpl({
    required MissionRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<List<UserMissionModel>> getMyMissions() async {
    final stopwatch = Stopwatch()..start();
    LogHandler.info('[MissionRepository] -> Fetching my missions');

    final token = await _localDataSource.getToken();
    if (token == null || token.isEmpty) {
      LogHandler.error(
        '[MissionRepository] Missing auth token for mission fetch',
      );
      throw Exception('No authentication token found');
    }

    try {
      final missions = await _remoteDataSource.getMyMissions(token);
      stopwatch.stop();
      LogHandler.success(
        '[MissionRepository] <- Received ${missions.length} missions '
        'in ${stopwatch.elapsedMilliseconds}ms',
      );
      return missions;
    } catch (e, st) {
      stopwatch.stop();
      LogHandler.error(
        '[MissionRepository] Mission fetch failed '
        'after ${stopwatch.elapsedMilliseconds}ms',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
