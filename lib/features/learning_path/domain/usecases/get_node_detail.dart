import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class GetNodeDetail {
  final LearningPathRepository repository;

  GetNodeDetail(this.repository);

  Future<NodeDetail> call(String nodeId) async {
    return await repository.getNodeDetail(nodeId);
  }
}
