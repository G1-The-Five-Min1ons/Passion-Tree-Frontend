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

class EnrollPathEvent extends LearningPathEvent {
  final String pathId;
  final String userId;
  EnrollPathEvent({required this.pathId, required this.userId});
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

// ===== TEACHER EVENTS =====

class CreateLearningPathEvent extends LearningPathEvent {
  final String title;
  final String objective;
  final String description;
  final String creatorId;
  final String? coverImgUrl;
  final String publishStatus;

  CreateLearningPathEvent({
    required this.title,
    required this.objective,
    required this.description,
    required this.creatorId,
    this.coverImgUrl,
    this.publishStatus = 'draft',
  });
}

class GenerateNodesWithAIEvent extends LearningPathEvent {
  final String topic;
  
  GenerateNodesWithAIEvent({required this.topic});
}

class CreateNodeEvent extends LearningPathEvent {
  final String title;
  final String description;
  final String pathId;
  final String sequence;
  final String linkvdo;
  
  CreateNodeEvent({
    required this.title,
    this.description = '',
    required this.pathId,
    required this.sequence,
    this.linkvdo = '',
  });
}

class GetLearningPathByIdEvent extends LearningPathEvent {
  final String pathId;
  
  GetLearningPathByIdEvent({required this.pathId});
}

class UpdateNodeEvent extends LearningPathEvent {
  final String nodeId;
  final String title;
  final String description;
  
  UpdateNodeEvent({
    required this.nodeId,
    required this.title,
    required this.description,
  });
}

