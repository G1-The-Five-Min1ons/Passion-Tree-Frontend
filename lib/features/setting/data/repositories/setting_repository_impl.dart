import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failure_mapper.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/features/setting/data/datasources/setting_remote_data_source.dart';
import 'package:passion_tree_frontend/features/setting/data/mappers/setting_mapper.dart';
import 'package:passion_tree_frontend/features/setting/domain/entities/setting_item.dart';
import 'package:passion_tree_frontend/features/setting/domain/repositories/setting_repository.dart';

class SettingRepositoryImpl implements ISettingRepository {
  final SettingRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  SettingRepositoryImpl({
    required SettingRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<SettingItem>>> getSettings() async {
    try {
      final token = await _localDataSource.getToken();
      if (token == null || token.isEmpty) {
        LogHandler.warning('SETTING REPO · GET SETTINGS aborted: missing token');
        return left(const AuthFailure.unauthorized());
      }

      final models = await _remoteDataSource.getSettings(token);
      final entities = models.map(SettingMapper.toEntity).toList();
      return right(entities);
    } catch (e) {
      LogHandler.error('SETTING REPO · GET SETTINGS failed: $e');
      return left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateSetting({
    required String key,
    required String value,
  }) async {
    try {
      final token = await _localDataSource.getToken();
      if (token == null || token.isEmpty) {
        LogHandler.warning('SETTING REPO · UPDATE aborted: missing token');
        return left(const AuthFailure.unauthorized());
      }

      await _remoteDataSource.updateSetting(token: token, key: key, value: value);
      return right(null);
    } catch (e) {
      LogHandler.error('SETTING REPO · UPDATE SETTING failed: key=$key, error=$e');
      return left(FailureMapper.fromException(e));
    }
  }
}
