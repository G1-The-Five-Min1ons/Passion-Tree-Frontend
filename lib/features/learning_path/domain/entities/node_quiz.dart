//ของครู
class NodeQuiz {
  final String question;
  final List<String> choices;
  final int selectedIndex;
  final Map<int, String> reasons;
  final String? questionId; // ID สำหรับ questions ที่มีอยู่แล้ว
  final List<String>? choiceIds; // IDs สำหรับ choices ที่มีอยู่แล้ว

  const NodeQuiz({
    this.question = '',
    this.choices = const ['', ''], //default 2 choices
    this.selectedIndex = 0,
    this.reasons = const {},
    this.questionId,
    this.choiceIds,
  });

  NodeQuiz copyWith({
    String? question,
    List<String>? choices,
    int? selectedIndex,
    Map<int, String>? reasons,
    String? questionId,
    List<String>? choiceIds,
  }) {
    return NodeQuiz(
      question: question ?? this.question,
      choices: choices ?? this.choices,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      reasons: reasons ?? this.reasons,
      questionId: questionId ?? this.questionId,
      choiceIds: choiceIds ?? this.choiceIds,
    );
  }
}
