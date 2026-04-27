import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class AIAnalysisContent extends StatelessWidget {
  final String sentiment;
  final double reflectScore;
  final String summary;
  final String strugglePoint;

  const AIAnalysisContent({
    super.key,
    required this.sentiment,
    required this.reflectScore,
    required this.summary,
    required this.strugglePoint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Results',
          style: AppTypography.h3SemiBold.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Overall  : ',
                style: AppTypography.titleSemiBold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Text(
                sentiment,
                textAlign: TextAlign.right,
                style: AppTypography.titleRegular.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildScoreLine("Quality of Reflection  :", reflectScore),

        const SizedBox(height: 14),
        Text(
          'Summary  : ',
          style: AppTypography.titleSemiBold.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 5),
        Text(
          summary,
          style: AppTypography.titleRegular.copyWith(color: AppColors.textPrimary),
        ),

        const SizedBox(height: 14),
        Text(
          'Struggle Point  : ',
          style: AppTypography.titleSemiBold.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 5),
        Text(
          strugglePoint,
          style: AppTypography.titleRegular.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildScoreLine(String label, double val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: AppTypography.titleSemiBold.copyWith(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            "${val.toStringAsFixed(val % 1 == 0 ? 0 : 1)}/10",
            textAlign: TextAlign.right,
            style: AppTypography.titleRegular.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
