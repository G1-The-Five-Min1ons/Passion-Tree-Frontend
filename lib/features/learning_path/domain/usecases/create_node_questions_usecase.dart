import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_question_with_choices.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

class CreateNodeQuestionsUseCase {
  final LearningPathRepository repository;

  CreateNodeQuestionsUseCase(this.repository);

  Future<void> call(
    String nodeId,
    List<CreateQuestionWithChoices> questions,
  ) async {
    return await repository.createNodeQuestions(nodeId, questions);
  }
}
