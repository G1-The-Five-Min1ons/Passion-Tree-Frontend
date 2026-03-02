
import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/radio.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/quiz_question.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class QuizResultQuestionWidget extends StatelessWidget {
  final QuizQuestion question;

  const QuizResultQuestionWidget({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== QUESTION =====
          Text(
            question.questionText,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: colors.onSurface),
          ),

          const SizedBox(height: 12),

          // ===== CHOICES =====
          ...List.generate(question.choices.length, (cIndex) {
            final bool isSelected = question.selectedIndex == cIndex;
            final bool isCorrect = question.correctIndex == cIndex;

            Color textColor = colors.onSurface;

            if (isCorrect) {
              textColor = AppColors.status; 
            } else if (isSelected && !question.isCorrect) {
              textColor = AppColors.cancel;
            }


            return Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Row(
                children: [
                  PixelRadioButton(index: cIndex + 1, isSelected: isSelected),
                  const SizedBox(width: 26),
                  Expanded(
                    child: Text(
                      question.choices[cIndex].choiceText,
                      style: AppTypography.subtitleSemiBold.copyWith(
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // ===== REASON =====
          RichText(
            text: TextSpan(
              style: AppTypography.titleSemiBold,
              children: [
                TextSpan(
                  text: 'Reason: ',
                  style: AppTypography.titleSemiBold,
                ),
                TextSpan(
                  text: question.correctReasoning,
                  style: AppTypography.subtitleSemiBold.copyWith(
                    color: AppColors.textSecondary, 
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
