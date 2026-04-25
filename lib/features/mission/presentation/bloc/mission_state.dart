import 'package:passion_tree_frontend/features/mission/data/models/user_mission_model.dart';

abstract class MissionState {
  const MissionState();
}

class MissionInitial extends MissionState {
  const MissionInitial();
}

class MissionLoading extends MissionState {
  const MissionLoading();
}

class MissionLoaded extends MissionState {
  final List<UserMissionModel> missions;

  const MissionLoaded(this.missions);
}

class MissionError extends MissionState {
  final String message;
  final List<UserMissionModel> previousMissions;

  const MissionError(
    this.message, {
    this.previousMissions = const <UserMissionModel>[],
  });
}
