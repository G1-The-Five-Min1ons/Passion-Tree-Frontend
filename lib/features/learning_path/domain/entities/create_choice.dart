class CreateChoice {
  final String choiceText;
  final bool isCorrect;
  final String reasoning;

  const CreateChoice({
    required this.choiceText,
    required this.isCorrect,
    this.reasoning = '',
  });
}
