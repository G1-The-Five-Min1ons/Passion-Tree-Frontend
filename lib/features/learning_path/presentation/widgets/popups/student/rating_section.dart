import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class RatingSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const RatingSection({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleSemiBold.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTypography.subtitleRegular),
        const SizedBox(height: 12),

        // 🔹 ตรงนี้เว้นไว้ก่อน ยังไม่ใส่วงกลม
        const SizedBox(height: 40),
      ],
    );
  }
}
