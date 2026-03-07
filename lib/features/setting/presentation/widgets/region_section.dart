import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';

class RegionSection extends StatelessWidget {
  const RegionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return PixelBorderContainer(
      pixelSize: 4,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Region',
            style: AppTypography.titleSemiBold.copyWith(color: AppColors.title),
          ),
          const SizedBox(height: 12),
          _buildInfoPair('Time Zone', '(GMT+7) Bangkok, Hanoi, Jakarta'),
          const Divider(color: AppColors.cardBorder, height: 20),
          _buildInfoPair('Date Format', 'DD/MM/YYYY'),
        ],
      ),
    );
  }

  Widget _buildInfoPair(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.subtitleMedium.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyRegular.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
