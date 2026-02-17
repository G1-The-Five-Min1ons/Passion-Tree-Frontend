/// Entity สำหรับ Quiz Question และ Choice จาก backend
class QuizQuestion {
  final String questionId;
  final String questionText;
  final String type;
  final String nodeId;
  final List<QuizChoice> choices;

  /// index ของคำตอบที่นักเรียนเลือก (ใช้ในหน้า UI)
  int? selectedIndex;

  QuizQuestion({
    required this.questionId,
    required this.questionText,
    required this.type,
    required this.nodeId,
    required this.choices,
    this.selectedIndex,
  });

  /// คำนวณว่าคำตอบที่เลือกถูกต้องหรือไม่
  bool get isCorrect {
    if (selectedIndex == null) return false;
    if (selectedIndex! >= choices.length) return false;
    return choices[selectedIndex!].isCorrect;
  }

  /// หา index ของคำตอบที่ถูกต้อง
  int? get correctIndex {
    for (int i = 0; i < choices.length; i++) {
      if (choices[i].isCorrect) {
        return i;
      }
    }
    return null;
  }

  /// หาเหตุผลของคำตอบที่ถูกต้อง
  String get correctReasoning {
    final correctChoice = choices.firstWhere(
      (choice) => choice.isCorrect,
      orElse: () => choices.first,
    );
    return correctChoice.reasoning;
  }

  QuizQuestion copyWith({
    String? questionId,
    String? questionText,
    String? type,
    String? nodeId,
    List<QuizChoice>? choices,
    int? selectedIndex,
  }) {
    return QuizQuestion(
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      type: type ?? this.type,
      nodeId: nodeId ?? this.nodeId,
      choices: choices ?? this.choices,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class QuizChoice {
  final String choiceId;
  final String choiceText;
  final bool isCorrect;
  final String reasoning;
  final String questionId;

  const QuizChoice({
    required this.choiceId,
    required this.choiceText,
    required this.isCorrect,
    required this.reasoning,
    required this.questionId,
  });

  QuizChoice copyWith({
    String? choiceId,
    String? choiceText,
    bool? isCorrect,
    String? reasoning,
    String? questionId,
  }) {
    return QuizChoice(
      choiceId: choiceId ?? this.choiceId,
      choiceText: choiceText ?? this.choiceText,
      isCorrect: isCorrect ?? this.isCorrect,
      reasoning: reasoning ?? this.reasoning,
      questionId: questionId ?? this.questionId,
    );
  }
}
