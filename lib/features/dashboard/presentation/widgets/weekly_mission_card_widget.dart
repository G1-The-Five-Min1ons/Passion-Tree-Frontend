import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';

class WeeklyMissionCardWidget extends StatelessWidget {
  const WeeklyMissionCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PixelBorderContainer(
      pixelSize: 3,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Weekly Mission!',
                style: AppPixelTypography.smallTitle.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '60%',
                style: AppTypography.titleSemiBold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildMissionProgress('Complete daily login', 6 / 7, '6/7'),
          const SizedBox(height: 8),
          _buildMissionProgress('Take quiz', 0 / 10, '0/10'),
          const SizedBox(height: 8),
          _buildMissionProgress('Watch Videos', 6 / 7, '6/7'),
        ],
      ),
    );
  }

  Widget _buildMissionProgress(String title, double value, String trailing) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                trailing,
                style: AppTypography.smallBodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.cardBorder,
            color: AppColors.secondaryBrand,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
