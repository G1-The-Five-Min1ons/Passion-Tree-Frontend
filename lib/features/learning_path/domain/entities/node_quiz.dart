class NodeQuiz {
  final String question;
  final List<String> choices;
  final int selectedIndex;
  final Map<int, String> reasons;

  const NodeQuiz({
    this.question = '',
     this.choices = const ['', ''],//default 2 choices
    this.selectedIndex = 0,
    this.reasons = const {},
  });

  NodeQuiz copyWith({
    String? question,
    List<String>? choices,
    int? selectedIndex,
    Map<int, String>? reasons,
  }) {
    return NodeQuiz(
      question: question ?? this.question,
      choices: choices ?? this.choices,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      reasons: reasons ?? this.reasons,
    );
  }
}
