import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class CompleteNode {
  final LearningPathRepository repository;

  CompleteNode(this.repository);

  Future<void> call(String nodeId, String userId) async {
    return await repository.completeNode(nodeId, userId);
  }
}
