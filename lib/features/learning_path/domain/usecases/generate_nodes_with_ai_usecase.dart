import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/ai_generate_response.dart';

class GenerateNodesWithAIUseCase {
  final LearningPathRepository repository;

  GenerateNodesWithAIUseCase(this.repository);

  Future<AIGenerateResponse> call(String topic) async {
    return await repository.generateNodesWithAI(topic);
  }
}
