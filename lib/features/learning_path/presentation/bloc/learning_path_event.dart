import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_material.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_question_with_choices.dart';

abstract class LearningPathEvent {}

class FetchLearningPaths extends LearningPathEvent {}

class FetchLearningPathStatus extends LearningPathEvent {}

class FetchLearningPathOverview extends LearningPathEvent {}

class FetchNodesForPath extends LearningPathEvent {
  final String pathId;
  FetchNodesForPath({required this.pathId});
}

class FetchNodeDetail extends LearningPathEvent {
  final String nodeId;
  FetchNodeDetail({required this.nodeId});
}

class StartNodeEvent extends LearningPathEvent {
  final String nodeId;
  StartNodeEvent({required this.nodeId});
}

class EnrollPathEvent extends LearningPathEvent {
  final String pathId;
  EnrollPathEvent({required this.pathId});
}

class CompleteNodeEvent extends LearningPathEvent {
  final String nodeId;
  CompleteNodeEvent({required this.nodeId});
}

class SubmitReviewEvent extends LearningPathEvent {
  final String pathId;
  final int contentQualityRating;
  final int instructorRating;
  final int overallRating;
  
  SubmitReviewEvent({
    required this.pathId,
    required this.contentQualityRating,
    required this.instructorRating,
    required this.overallRating,
  });
}

class DeleteLearningPathEvent extends LearningPathEvent {
  final String pathId;
  final String? publishStatus; // 'draft' or 'published' for snackbar message
  DeleteLearningPathEvent({required this.pathId, this.publishStatus});
}

class DeleteNodeEvent extends LearningPathEvent {
  final String nodeId;

  DeleteNodeEvent({required this.nodeId});
}

class ReorderNodesEvent extends LearningPathEvent {
  final String pathId;
  final List<String> nodeIds;

  ReorderNodesEvent({required this.pathId, required this.nodeIds});
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
  final List<CreateMaterial>? materials;
  final List<CreateQuestionWithChoices>? questions;
  
  CreateNodeEvent({
    required this.title,
    this.description = '',
    required this.pathId,
    required this.sequence,
    this.linkvdo = '',
    this.materials,
    this.questions,
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
  final String? linkvdo;
  final List<CreateMaterial>? materials;
  final List<CreateQuestionWithChoices>? questions;
  
  UpdateNodeEvent({
    required this.nodeId,
    required this.title,
    required this.description,
    this.linkvdo,
    this.materials,
    this.questions,
  });
}

class UpdateLearningPathEvent extends LearningPathEvent {
  final String pathId;
  final String title;
  final String objective;
  final String description;
  final String? coverImgUrl;
  final String publishStatus;

  UpdateLearningPathEvent({
    required this.pathId,
    required this.title,
    required this.objective,
    required this.description,
    this.coverImgUrl,
    this.publishStatus = 'draft',
  });
}

