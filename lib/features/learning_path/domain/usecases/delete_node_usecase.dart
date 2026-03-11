import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class DeleteNodeUseCase {
  final LearningPathRepository repository;

  DeleteNodeUseCase(this.repository);

  Future<void> call(String nodeId) async {
    return await repository.deleteNode(nodeId);
  }
}
