import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';

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


class LearningPathError extends LearningPathState {
  final String message;

  LearningPathError(this.message);
}
