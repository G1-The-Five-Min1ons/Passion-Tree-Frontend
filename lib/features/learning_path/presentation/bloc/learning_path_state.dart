import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';

abstract class LearningPathState {}

class LearningPathInitial extends LearningPathState {}

class LearningPathLoading extends LearningPathState {}

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

class LearningPathDeleted extends LearningPathState {
  final String message;

  LearningPathDeleted(this.message);
}

class LearningPathError extends LearningPathState {
  final String message;

  LearningPathError(this.message);
}
