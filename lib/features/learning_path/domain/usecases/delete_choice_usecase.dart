import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class DeleteChoiceUseCase {
  final LearningPathRepository repository;

  DeleteChoiceUseCase(this.repository);

  Future<void> call(String choiceId) async {
    return await repository.deleteChoice(choiceId);
  }
}
