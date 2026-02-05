class QuizStudent {
  final String title;
  final List<QuizQuestionStudent> questions;

  QuizStudent({required this.title, required this.questions});
}

class QuizQuestionStudent {
  final String question;
  final List<String> choices;

  /// index ของคำตอบที่นักเรียนเลือก
  int? selectedIndex;

  /// index ของคำตอบที่ถูก (ใช้ตอนเฉลย)
  final int correctIndex;

  final String reason;

  QuizQuestionStudent({
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.reason,
    this.selectedIndex,
  });

  bool get isCorrect => selectedIndex == correctIndex;
}
