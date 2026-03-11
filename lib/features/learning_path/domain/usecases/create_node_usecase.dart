import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_node.dart';

class CreateNodeUseCase {
  final LearningPathRepository repository;

  CreateNodeUseCase(this.repository);

  Future<String> call(CreateNode node) async {
    return await repository.createNode(node);
  }
}
