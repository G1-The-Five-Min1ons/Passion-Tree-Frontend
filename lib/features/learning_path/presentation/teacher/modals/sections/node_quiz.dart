import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/inline_text_field.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/radio.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_quiz.dart';

class NodeQuizSection extends StatefulWidget {
  final List<NodeQuiz>? initialQuizzes;
  final ValueChanged<List<NodeQuiz>>? onQuizzesChanged;

  const NodeQuizSection({
    super.key,
    this.initialQuizzes,
    this.onQuizzesChanged,
  });

  @override
  State<NodeQuizSection> createState() => _NodeQuizSectionState();
}

class _NodeQuizSectionState extends State<NodeQuizSection> {
  // ===== STATE =====
  late List<NodeQuiz> _quizzes;

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลเดิมหรือสร้าง default quiz
    _quizzes = widget.initialQuizzes != null && widget.initialQuizzes!.isNotEmpty
        ? List<NodeQuiz>.from(widget.initialQuizzes!)
        : [const NodeQuiz()];
  }

  @override
  void didUpdateWidget(NodeQuizSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // อัพเดท _quizzes เมื่อ parent ส่ง initialQuizzes ใหม่มา
    if (widget.initialQuizzes != oldWidget.initialQuizzes) {
      _quizzes = widget.initialQuizzes != null && widget.initialQuizzes!.isNotEmpty
          ? List<NodeQuiz>.from(widget.initialQuizzes!)
          : [const NodeQuiz()];
    }
  }

  void _notifyChange() {
    widget.onQuizzesChanged?.call(_quizzes);
  }

  // ===== ACTIONS =====
  void _addQuestion() {
    setState(() {
      _quizzes.add(const NodeQuiz());
    });
    _notifyChange();
  }

  void _removeQuestion(int index) {
    setState(() {
      _quizzes.removeAt(index);
    });
    _notifyChange();
  }

  void _addChoice(int qIndex) {
    final quiz = _quizzes[qIndex];
    setState(() {
      _quizzes[qIndex] = quiz.copyWith(choices: [...quiz.choices, '']);
    });
    _notifyChange();
  }

  void _removeChoice(int qIndex, int cIndex) {
    final quiz = _quizzes[qIndex];
    final newChoices = [...quiz.choices]..removeAt(cIndex);
    final newReasons = Map<int, String>.from(quiz.reasons)..remove(cIndex);

    setState(() {
      _quizzes[qIndex] = quiz.copyWith(
        choices: newChoices,
        reasons: newReasons,
        selectedIndex: quiz.selectedIndex >= newChoices.length
            ? 0
            : quiz.selectedIndex,
      );
    });
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question (Optional)', style: AppTypography.titleSemiBold),
        const SizedBox(height: 8),

        // ===== QUIZ LIST =====
        ...List.generate(_quizzes.length, (qIndex) {
          final quiz = _quizzes[qIndex];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== QUESTION =====
                  Row(
                    children: [
                      Text(
                        '${qIndex + 1}',
                        style: AppTypography.subtitleSemiBold,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InlineTextField(
                          hintText: 'Enter question',
                          value: quiz.question,
                          onChanged: (v) {
                            setState(() {
                              _quizzes[qIndex] = quiz.copyWith(question: v);
                            });
                            _notifyChange();
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 18, color: colors.error),
                        onPressed: () => _removeQuestion(qIndex),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ===== CHOICES =====
                  ...List.generate(quiz.choices.length, (cIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _quizzes[qIndex] = quiz.copyWith(
                                      selectedIndex: cIndex,
                                    );
                                  });
                                  _notifyChange();
                                },
                                child: PixelRadioButton(
                                  index: cIndex + 1,
                                  isSelected: quiz.selectedIndex == cIndex,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InlineTextField(
                                  hintText: 'Choice',
                                  value: quiz.choices[cIndex],
                                  onChanged: (v) {
                                    final updatedChoices = [...quiz.choices];
                                    updatedChoices[cIndex] = v;

                                    setState(() {
                                      _quizzes[qIndex] = quiz.copyWith(
                                        choices: updatedChoices,
                                      );
                                    });
                                    _notifyChange();
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: colors.error,
                                ),
                                onPressed: () => _removeChoice(qIndex, cIndex),
                              ),
                            ],
                          ),

                          // ===== REASON =====
                          if (quiz.selectedIndex == cIndex)
                            Padding(
                              padding: const EdgeInsets.only(left: 40, top: 6),
                              child: Row(
                                children: [
                                  Text(
                                    'Reason:',
                                    style: AppTypography.subtitleSemiBold,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: InlineTextField(
                                      hintText: 'Explain why this is correct',
                                      value: quiz.reasons[cIndex] ?? '',
                                      showUnderline: true,
                                      onChanged: (v) {
                                        final newReasons =
                                            Map<int, String>.from(quiz.reasons);
                                        newReasons[cIndex] = v;

                                        setState(() {
                                          _quizzes[qIndex] = quiz.copyWith(
                                            reasons: newReasons,
                                          );
                                        });
                                        _notifyChange();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  // ===== ADD CHOICE =====
                  TextButton(
                    onPressed: () => _addChoice(qIndex),
                    child: Text(
                      'Add More Choices',
                      style: AppTypography.subtitleSemiBold.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // ===== ADD QUESTION =====
        TextButton(
          onPressed: _addQuestion,
          child: Text(
            'Add More Questions',
            style: AppTypography.subtitleSemiBold.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

