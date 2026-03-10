import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_choice.dart';

class CreateQuestionWithChoices {
  final String questionText;
  final String type;
  final List<CreateChoice> choices;

  const CreateQuestionWithChoices({
    required this.questionText,
    required this.type,
    required this.choices,
  });
}
