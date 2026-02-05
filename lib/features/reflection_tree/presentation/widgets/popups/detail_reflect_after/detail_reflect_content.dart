import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class DetailReflectContent extends StatelessWidget {
  final String learn;
  final String feel;
  final int progress;
  final int challenge;

  const DetailReflectContent({
    super.key,
    this.learn = "วันนี้ได้ทบทวนเรื่องโครงสร้างเซลล์",
    this.feel = "รู้สึกเข้าใจเนื้อหามากขึ้นหลังจากเรียน",
    this.progress = 4,
    this.challenge = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("You've learned :", 
          style: AppTypography.titleSemiBold.copyWith(color: AppColors.surface)),
        const SizedBox(height: 8),
        Text(learn, 
          style: AppTypography.subtitleRegular.copyWith(color: AppColors.surface)),

        const SizedBox(height: 20),
        Text("You felt :", 
          style: AppTypography.titleSemiBold.copyWith(color: AppColors.surface)),
        const SizedBox(height: 8),
        Text(feel, 
          style: AppTypography.subtitleRegular.copyWith(color: AppColors.surface)),
        const SizedBox(height: 30),
        _buildScoreLine("Progress", progress),
        const SizedBox(height: 15),
        _buildScoreLine("Challenge", challenge),
      ],
    );
  }
  Widget _buildScoreLine(String label, int val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.titleSemiBold.copyWith(color: AppColors.surface)),
        Text("$val/5", 
          style: AppTypography.titleSemiBold.copyWith(color: AppColors.surface)),
      ],
    );
  }
}