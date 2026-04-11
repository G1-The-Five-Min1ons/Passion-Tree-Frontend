import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';

List<MissionItem> buildMockWeeklyMissions() {
  final now = DateTime.now();

  return [
    MissionItem(
      missionId: 'mock-mission-1',
      detail: 'Complete 1 learning node',
      rewardXp: 120,
      status: 'pending',
      expireAt: now.add(const Duration(days: 6)),
    ),
    MissionItem(
      missionId: 'mock-mission-2',
      detail: 'Study for at least 2 hours this week',
      rewardXp: 180,
      status: 'pending',
      expireAt: now.add(const Duration(days: 5)),
    ),
    MissionItem(
      missionId: 'mock-mission-3',
      detail: 'Finish your weekly reflection',
      rewardXp: 140,
      status: 'completed',
      expireAt: now.add(const Duration(days: 4)),
    ),
  ];
}

List<MissionItem> resolveWeeklyMissions(List<MissionItem> backendMissions) {
  if (backendMissions.isNotEmpty) {
    return backendMissions;
  }
  return buildMockWeeklyMissions();
}
