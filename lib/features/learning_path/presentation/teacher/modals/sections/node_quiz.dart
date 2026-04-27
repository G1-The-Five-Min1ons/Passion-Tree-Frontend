import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/inline_text_field.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/radio.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_quiz.dart';

class NodeQuizSection extends StatefulWidget {
  final List<NodeQuiz>? initialQuizzes;
  final ValueChanged<List<NodeQuiz>>? onQuizzesChanged;
  final bool isReadOnly;
  final bool isQuizInvalid;

  const NodeQuizSection({
    super.key,
    this.initialQuizzes,
    this.onQuizzesChanged,
    this.isReadOnly = false,
    this.isQuizInvalid = false,
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
    _quizzes =
        widget.initialQuizzes != null && widget.initialQuizzes!.isNotEmpty
        ? List<NodeQuiz>.from(widget.initialQuizzes!)
        : [const NodeQuiz()];
  }

  @override
  void didUpdateWidget(NodeQuizSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // อัพเดท _quizzes เมื่อ parent ส่ง initialQuizzes ใหม่มา
    if (widget.initialQuizzes != oldWidget.initialQuizzes) {
      _quizzes =
          widget.initialQuizzes != null && widget.initialQuizzes!.isNotEmpty
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
    final updatedChoiceIds = quiz.choiceIds == null
        ? null
        : [...quiz.choiceIds!, ''];
    setState(() {
      _quizzes[qIndex] = quiz.copyWith(
        choices: [...quiz.choices, ''],
        choiceIds: updatedChoiceIds,
      );
    });
    _notifyChange();
  }

  void _removeChoice(int qIndex, int cIndex) {
    final quiz = _quizzes[qIndex];
    final newChoices = [...quiz.choices]..removeAt(cIndex);
    final newReasons = <int, String>{};
    for (final entry in quiz.reasons.entries) {
      if (entry.key == cIndex) continue;
      final shiftedIndex = entry.key > cIndex ? entry.key - 1 : entry.key;
      newReasons[shiftedIndex] = entry.value;
    }

    List<String>? newChoiceIds;
    if (quiz.choiceIds != null) {
      final ids = [...quiz.choiceIds!];
      if (cIndex >= 0 && cIndex < ids.length) {
        ids.removeAt(cIndex);
      }
      newChoiceIds = ids;
    }

    final newSelectedIndex = quiz.selectedIndex == cIndex
        ? (newChoices.isEmpty
              ? 0
              : (cIndex >= newChoices.length ? newChoices.length - 1 : cIndex))
        : (quiz.selectedIndex > cIndex
              ? quiz.selectedIndex - 1
              : quiz.selectedIndex);

    setState(() {
      _quizzes[qIndex] = quiz.copyWith(
        choices: newChoices,
        reasons: newReasons,
        selectedIndex: newSelectedIndex < 0 ? 0 : newSelectedIndex,
        choiceIds: newChoiceIds,
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
        RichText(
          text: TextSpan(
            style: AppTypography.titleSemiBold.copyWith(
              color: widget.isQuizInvalid
                  ? AppColors.cancel
                  : Theme.of(context).colorScheme.onSurface,
            ),
            children: const [
              TextSpan(text: 'Question'),
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.cancel),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        if (widget.isQuizInvalid)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Please add at least 1 question with 2 or more choices.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.cancel),
            ),
          ),

        // ===== QUIZ LIST =====
        ...List.generate(_quizzes.length, (qIndex) {
          final quiz = _quizzes[qIndex];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.isQuizInvalid
                      ? AppColors.cancel
                      : AppColors.textSecondary.withValues(alpha: 0.4),
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
                          readOnly: widget.isReadOnly,
                          onChanged: (v) {
                            if (widget.isReadOnly) return;
                            setState(() {
                              _quizzes[qIndex] = quiz.copyWith(question: v);
                            });
                            _notifyChange();
                          },
                        ),
                      ),
                      if (!widget.isReadOnly)
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: colors.error,
                          ),
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
                                onTap: widget.isReadOnly
                                    ? null
                                    : () {
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
                                  readOnly: widget.isReadOnly,
                                  onChanged: (v) {
                                    if (widget.isReadOnly) return;
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
                              if (!widget.isReadOnly)
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: colors.error,
                                  ),
                                  onPressed: () =>
                                      _removeChoice(qIndex, cIndex),
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
                                      readOnly: widget.isReadOnly,
                                      onChanged: (v) {
                                        if (widget.isReadOnly) return;
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
                  if (!widget.isReadOnly)
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
        if (!widget.isReadOnly)
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
