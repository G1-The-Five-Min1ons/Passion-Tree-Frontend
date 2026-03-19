import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/features/setting/domain/entities/setting_item.dart';

abstract class ISettingRepository {
  Future<Either<Failure, List<SettingItem>>> getSettings();
  Future<Either<Failure, void>> updateSetting({
    required String key,
    required String value,
  });
}
