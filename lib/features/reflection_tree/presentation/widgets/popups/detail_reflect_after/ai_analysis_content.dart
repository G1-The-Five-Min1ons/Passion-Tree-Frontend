import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class AIAnalysisContent extends StatelessWidget {
  final String sentiment;
  final int reflectScore;
  final String summary;
  final String strugglePoint;

  const AIAnalysisContent({
    //TODO:ใช้ค่าจริงจาก db
    super.key,
    this.sentiment = "Positive",
    this.reflectScore = 8,
    this.summary = "การเรียนรู้ของนักเรียนในครั้งนี้ดีมาก นักเรียนมีปัญหาเล็กน้อยในการแยกเซลล์",
    this.strugglePoint = "การแยกเซลล์"
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Results',
          style: AppTypography.h3SemiBold.copyWith(color: AppColors.surface)
        ),
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall  : ',
              style: AppTypography.titleSemiBold.copyWith(color: AppColors.surface)
            ),
            Text(
              sentiment,
              style: AppTypography.titleRegular.copyWith(color: AppColors.surface)
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildScoreLine("Quality of Reflection  :", reflectScore),

        const SizedBox(height: 14),
        Text(
          'Summary  : ',
          style: AppTypography.titleSemiBold.copyWith(color: AppColors.surface)
        ),
        const SizedBox(height: 5),
        Text(
          summary,
          style: AppTypography.titleRegular.copyWith(color: AppColors.surface)
        ),

        const SizedBox(height: 14),
        Text(
          'Struggle Point  : ',
          style: AppTypography.titleSemiBold.copyWith(color: AppColors.surface)
        ),
        const SizedBox(height: 5),
        Text(
          strugglePoint,
          style: AppTypography.titleRegular.copyWith(color: AppColors.surface)
        ),
      ],
    );
  }
  Widget _buildScoreLine(String label, int val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.titleSemiBold.copyWith(color: AppColors.surface)),
        Text("$val/10", 
          style: AppTypography.titleRegular.copyWith(color: AppColors.surface)),
      ],
    );
  }
  
}