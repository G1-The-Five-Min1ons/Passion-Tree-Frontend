import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class ReorderNodesUseCase {
  final LearningPathRepository repository;

  ReorderNodesUseCase(this.repository);

  Future<void> call(String pathId, List<String> nodeIds) async {
    return await repository.reorderNodes(pathId, nodeIds);
  }
}
