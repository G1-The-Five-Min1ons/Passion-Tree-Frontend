import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class GetNodesForPath {
  final LearningPathRepository repository;

  GetNodesForPath(this.repository);

  Future<List<NodeDetail>> call(String pathId, String userId) {
    return repository.getNodesForPath(pathId, userId);
  }
}
