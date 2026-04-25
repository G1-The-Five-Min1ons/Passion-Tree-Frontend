import 'package:passion_tree_frontend/features/mission/data/models/user_mission_model.dart';

abstract class IMissionRepository {
  /// Fetch the authenticated user's active missions.
  Future<List<UserMissionModel>> getMyMissions();
}
