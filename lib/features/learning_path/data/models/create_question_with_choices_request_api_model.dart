import 'package:passion_tree_frontend/features/learning_path/data/models/create_choice_request_api_model.dart';

class CreateQuestionWithChoicesRequestApiModel {
  final String questionText;
  final String type;
  final List<CreateChoiceRequestApiModel> choices;

  CreateQuestionWithChoicesRequestApiModel({
    required this.questionText,
    required this.type,
    required this.choices,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_text': questionText,
      'type': type,
      'choice': choices.map((v) => v.toJson()).toList(),
    };
  }

  factory CreateQuestionWithChoicesRequestApiModel.fromJson(Map<String, dynamic> json) {
    var choicesList = json['choice'] as List? ?? [];
    List<CreateChoiceRequestApiModel> choices = 
        choicesList.map((i) => CreateChoiceRequestApiModel.fromJson(i)).toList();

    return CreateQuestionWithChoicesRequestApiModel(
      questionText: json['question_text'] ?? '',
      type: json['type'] ?? '',
      choices: choices,
    );
  }
}
