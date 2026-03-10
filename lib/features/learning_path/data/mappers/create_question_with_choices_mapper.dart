import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_question_with_choices.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_question_with_choices_request_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/create_choice_mapper.dart';

extension CreateQuestionWithChoicesMapper on CreateQuestionWithChoices {
  CreateQuestionWithChoicesRequestApiModel toApiModel() {
    return CreateQuestionWithChoicesRequestApiModel(
      questionText: questionText,
      type: type,
      choices: choices.map((c) => c.toApiModel()).toList(),
    );
  }
}

extension CreateQuestionWithChoicesRequestApiModelMapper on CreateQuestionWithChoicesRequestApiModel {
  CreateQuestionWithChoices toEntity() {
    return CreateQuestionWithChoices(
      questionText: questionText,
      type: type,
      choices: choices.map((c) => c.toEntity()).toList(),
    );
  }
}
