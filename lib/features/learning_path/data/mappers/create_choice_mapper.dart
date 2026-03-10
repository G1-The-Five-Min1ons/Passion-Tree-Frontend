import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_choice.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_choice_request_api_model.dart';

extension CreateChoiceMapper on CreateChoice {
  CreateChoiceRequestApiModel toApiModel() {
    return CreateChoiceRequestApiModel(
      choiceText: choiceText,
      isCorrect: isCorrect,
      reasoning: reasoning,
    );
  }
}

extension CreateChoiceRequestApiModelMapper on CreateChoiceRequestApiModel {
  CreateChoice toEntity() {
    return CreateChoice(
      choiceText: choiceText,
      isCorrect: isCorrect,
      reasoning: reasoning,
    );
  }
}
