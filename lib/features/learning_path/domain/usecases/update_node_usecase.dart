import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_material.dart';

class UpdateNodeUseCase {
  final LearningPathRepository repository;

  UpdateNodeUseCase(this.repository);

  Future<void> call(
    String nodeId,
    String title,
    String description, {
    String? linkvdo,
    List<CreateMaterial>? materials,
  }) async {
    return await repository.updateNode(
      nodeId,
      title,
      description,
      linkvdo: linkvdo,
      materials: materials,
    );
  }
}
