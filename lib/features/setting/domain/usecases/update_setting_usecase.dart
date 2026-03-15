import 'package:dartz/dartz.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/features/setting/domain/repositories/setting_repository.dart';

class UpdateSettingUseCase {
  final ISettingRepository _repository;

  UpdateSettingUseCase(this._repository);

  Future<Either<Failure, void>> execute({
    required String key,
    required String value,
  }) {
    return _repository.updateSetting(key: key, value: value);
  }
}
