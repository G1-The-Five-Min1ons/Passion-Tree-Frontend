abstract class LearningPathEvent {}

class FetchLearningPaths extends LearningPathEvent {}

class FetchLearningPathStatus extends LearningPathEvent {
  final String userId;
  FetchLearningPathStatus({required this.userId});
}

class FetchLearningPathOverview extends LearningPathEvent {
  final String? userId; // null if not logged in
  FetchLearningPathOverview({this.userId});
}

class FetchNodesForPath extends LearningPathEvent {
  final String pathId;
  FetchNodesForPath({required this.pathId});
}
