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
  final String userId;
  FetchNodesForPath({required this.pathId, required this.userId});
}

class FetchNodeDetail extends LearningPathEvent {
  final String nodeId;
  final String userId;
  FetchNodeDetail({required this.nodeId, required this.userId});
}

class StartNodeEvent extends LearningPathEvent {
  final String nodeId;
  final String userId;
  StartNodeEvent({required this.nodeId, required this.userId});
}

class CompleteNodeEvent extends LearningPathEvent {
  final String nodeId;
  final String userId;
  CompleteNodeEvent({required this.nodeId, required this.userId});
}

class DeleteLearningPathEvent extends LearningPathEvent {
  final String pathId;
  final String? userId; // For refreshing overview after delete
  DeleteLearningPathEvent({required this.pathId, this.userId});
}

