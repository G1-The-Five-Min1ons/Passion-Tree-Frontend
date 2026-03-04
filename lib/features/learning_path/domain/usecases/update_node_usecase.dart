import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class UpdateNodeUseCase {
  final LearningPathRepository repository;

  UpdateNodeUseCase(this.repository);

  Future<void> call(String nodeId, String title, String description) async {
    return await repository.updateNode(nodeId, title, description);
  }
}
