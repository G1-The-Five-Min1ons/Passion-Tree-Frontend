abstract class LearningPathEvent {}

class FetchLearningPaths extends LearningPathEvent {}

class FetchLearningPathStatus extends LearningPathEvent {
  final String userId;
  FetchLearningPathStatus({required this.userId});
}
