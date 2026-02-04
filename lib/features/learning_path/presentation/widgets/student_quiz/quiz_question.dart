import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/radio.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/student_quiz.dart';

class QuizQuestionWidget extends StatelessWidget {
  final QuizQuestionStudent question;
  final Function(int) onSelect;

  const QuizQuestionWidget({
    super.key,
    required this.question,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== QUESTION TEXT =====
          Text(
            question.question,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: colors.onSurface),
          ),

          const SizedBox(height: 12),

          // ===== CHOICES =====
          ...List.generate(
            question.choices.length,
            (cIndex) => InkWell(
              onTap: () => onSelect(cIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    PixelRadioButton(
                      index: cIndex + 1,
                      isSelected: question.selectedIndex == cIndex,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.choices[cIndex],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
