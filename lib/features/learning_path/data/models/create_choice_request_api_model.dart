class CreateChoiceRequestApiModel {
  final String choiceText;
  final bool isCorrect;
  final String reasoning;

  CreateChoiceRequestApiModel({
    required this.choiceText,
    required this.isCorrect,
    this.reasoning = '',
  });

  Map<String, dynamic> toJson() => {
    'choice_text': choiceText,
    'is_correct': isCorrect,
    'reasoning': reasoning,
  };

  factory CreateChoiceRequestApiModel.fromJson(Map<String, dynamic> json) {
    return CreateChoiceRequestApiModel(
      choiceText: json['choice_text'] ?? '',
      isCorrect: json['is_correct'] ?? false,
      reasoning: json['reasoning'] ?? '',
    );
  }
}
