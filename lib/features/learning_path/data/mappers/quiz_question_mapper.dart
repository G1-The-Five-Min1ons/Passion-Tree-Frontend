import 'package:passion_tree_frontend/features/learning_path/data/models/quiz_question_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/quiz_question.dart';

extension QuizChoiceMapper on QuizChoiceApiModel {
  QuizChoice toEntity() {
    return QuizChoice(
      choiceId: choiceId,
      choiceText: choiceText,
      isCorrect: isCorrect,
      reasoning: reasoning,
      questionId: questionId,
    );
  }
}

extension QuizQuestionMapper on QuizQuestionApiModel {
  QuizQuestion toEntity() {
    return QuizQuestion(
      questionId: questionId,
      questionText: questionText,
      type: type,
      nodeId: nodeId,
      choices: choices.map((c) => c.toEntity()).toList(),
    );
  }
}
