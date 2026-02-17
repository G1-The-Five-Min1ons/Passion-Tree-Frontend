import 'package:passion_tree_frontend/features/learning_path/domain/entities/quiz_question.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/learning_path_repository.dart';

/// Use case สำหรับดึงคำถาม quiz ของ node
class GetNodeQuestions {
  final LearningPathRepository repository;

  GetNodeQuestions(this.repository);

  Future<List<QuizQuestion>> call(String nodeId) async {
    return await repository.getNodeQuestions(nodeId);
  }
}
