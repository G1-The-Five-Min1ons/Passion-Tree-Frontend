/// API Model สำหรับ Quiz Choice
class QuizChoiceApiModel {
  final String choiceId;
  final String choiceText;
  final bool isCorrect;
  final String reasoning;
  final String questionId;

  const QuizChoiceApiModel({
    required this.choiceId,
    required this.choiceText,
    required this.isCorrect,
    required this.reasoning,
    required this.questionId,
  });

  factory QuizChoiceApiModel.fromJson(Map<String, dynamic> json) {
    return QuizChoiceApiModel(
      choiceId: json['choice_id'] as String,
      choiceText: json['choice_text'] as String,
      isCorrect: json['is_correct'] as bool,
      reasoning: json['reasoning'] as String? ?? '',
      questionId: json['question_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'choice_id': choiceId,
      'choice_text': choiceText,
      'is_correct': isCorrect,
      'reasoning': reasoning,
      'question_id': questionId,
    };
  }
}

/// API Model สำหรับ Quiz Question
class QuizQuestionApiModel {
  final String questionId;
  final String questionText;
  final String type;
  final String nodeId;
  final List<QuizChoiceApiModel> choices;

  const QuizQuestionApiModel({
    required this.questionId,
    required this.questionText,
    required this.type,
    required this.nodeId,
    required this.choices,
  });

  factory QuizQuestionApiModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionApiModel(
      questionId: json['question_id'] as String,
      questionText: json['question_text'] as String,
      type: json['type'] as String? ?? '',
      nodeId: json['node_id'] as String,
      choices: (json['choices'] as List<dynamic>?)
              ?.map((c) => QuizChoiceApiModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question_text': questionText,
      'type': type,
      'node_id': nodeId,
      'choices': choices.map((c) => c.toJson()).toList(),
    };
  }
}
