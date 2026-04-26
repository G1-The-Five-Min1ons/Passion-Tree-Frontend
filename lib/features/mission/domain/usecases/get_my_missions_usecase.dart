import 'package:passion_tree_frontend/features/mission/data/models/user_mission_model.dart';
import 'package:passion_tree_frontend/features/mission/domain/repositories/i_mission_repository.dart';

class GetMyMissionsUseCase {
  final IMissionRepository _repository;

  GetMyMissionsUseCase(this._repository);

  Future<List<UserMissionModel>> execute() => _repository.getMyMissions();
}
