import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/radio.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/quiz_question.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class QuizQuestionWidget extends StatelessWidget {
  final QuizQuestion question;
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
      padding: const EdgeInsets.only(bottom: 16),// ระยะห่างระหว่างคำถาม
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== QUESTION TEXT =====
          Text(
            question.questionText,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: colors.onSurface),
          ),

          const SizedBox(height: 18),// ระยะห่างระหว่างคำถามกับตัวเลือก

          // ===== CHOICES =====
          Column(
            children: List.generate(
              question.choices.length,
              (cIndex) => Column(
                children: [
                  InkWell(
                    onTap: () => onSelect(cIndex),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        children: [
                          PixelRadioButton(
                            index: cIndex + 1,
                            isSelected: question.selectedIndex == cIndex,
                          ),
                          const SizedBox(width: 26),// ระยะห่างระหว่างปุ่มเลือกกับข้อความ
                          Expanded(
                            child: Text(
                              question.choices[cIndex].choiceText,
                              style: AppTypography.subtitleSemiBold.copyWith(
                              color: colors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),// ระยะห่างระหว่างตัวเลือกแต่ละข้อ
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
