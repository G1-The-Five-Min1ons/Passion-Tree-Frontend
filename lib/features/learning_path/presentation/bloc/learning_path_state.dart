import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/generated_node.dart';

abstract class LearningPathState {}

class LearningPathInitial extends LearningPathState {}

/// Global loading state - use only when necessary
class LearningPathLoading extends LearningPathState {}

/// Operation-specific loading states
class DeletingLearningPath extends LearningPathState {
  final String pathId;
  DeletingLearningPath(this.pathId);
}

class DeletingNode extends LearningPathState {
  final String nodeId;
  DeletingNode(this.nodeId);
}

class EnrollingPath extends LearningPathState {
  final String pathId;
  EnrollingPath(this.pathId);
}

class StartingNode extends LearningPathState {
  final String nodeId;
  StartingNode(this.nodeId);
}

class CompletingNode extends LearningPathState {
  final String nodeId;
  CompletingNode(this.nodeId);
}

class CreatingLearningPath extends LearningPathState {}

class CreatingNode extends LearningPathState {}

class UpdatingNode extends LearningPathState {
  final String nodeId;
  UpdatingNode(this.nodeId);
}

class UpdatingLearningPath extends LearningPathState {
  final String pathId;
  UpdatingLearningPath(this.pathId);
}

class GeneratingNodesWithAI extends LearningPathState {}

class LearningPathLoaded extends LearningPathState {
  final List<LearningPath> paths;

  LearningPathLoaded(this.paths);
}

class LearningPathStatusLoaded extends LearningPathState {
  final List<EnrolledLearningPath> paths;

  LearningPathStatusLoaded(this.paths);
}

class LearningPathOverviewLoaded extends LearningPathState {
  final List<LearningPath> allPaths;
  final List<EnrolledLearningPath> enrolledPaths;

  LearningPathOverviewLoaded({
    required this.allPaths,
    required this.enrolledPaths,
  });
}

class NodesLoaded extends LearningPathState {
  final String pathId;
  final List<NodeDetail> nodes;

  NodesLoaded({
    required this.pathId,
    required this.nodes,
  });
}

class NodeDetailLoaded extends LearningPathState {
  final NodeDetail nodeDetail;

  NodeDetailLoaded(this.nodeDetail);
}

class PathEnrolled extends LearningPathState {
  final String pathId;
  final String userId;
  final EnrolledLearningPath enrolledPath;

  PathEnrolled({
    required this.pathId,
    required this.userId,
    required this.enrolledPath,
  });
}

class LearningPathDeleted extends LearningPathState {
  final String message;

  LearningPathDeleted(this.message);
}

class LearningPathError extends LearningPathState {
  final String message;

  LearningPathError(this.message);
}

// ===== TEACHER STATES =====

class LearningPathCreated extends LearningPathState {
  final String pathId;
  
  LearningPathCreated(this.pathId);
}

class NodesGeneratedWithAI extends LearningPathState {
  final String topic;
  final List<GeneratedNode> nodes;
  
  NodesGeneratedWithAI({
    required this.topic,
    required this.nodes,
  });
}

class NodeCreated extends LearningPathState {
  final String nodeId;
  
  NodeCreated(this.nodeId);
}

class LearningPathDetailLoaded extends LearningPathState {
  final LearningPath learningPath;
  
  LearningPathDetailLoaded(this.learningPath);
}

class NodeUpdated extends LearningPathState {
  final String nodeId;
  
  NodeUpdated(this.nodeId);
}

class NodeDeleted extends LearningPathState {
  final String nodeId;

  NodeDeleted(this.nodeId);
}

class LearningPathUpdated extends LearningPathState {
  final String pathId;
  
  LearningPathUpdated(this.pathId);
}
