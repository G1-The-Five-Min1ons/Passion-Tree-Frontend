import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/features/setting/domain/entities/setting_item.dart';
import 'package:passion_tree_frontend/features/setting/domain/repositories/setting_repository.dart';

class GetSettingsUseCase {
  final ISettingRepository _repository;

  GetSettingsUseCase(this._repository);

  Future<Either<Failure, List<SettingItem>>> execute() {
    return _repository.getSettings();
  }
}
