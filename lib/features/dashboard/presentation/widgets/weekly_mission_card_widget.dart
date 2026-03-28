import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';

class WeeklyMissionCardWidget extends StatelessWidget {
  final List<MissionItem> missions;

  const WeeklyMissionCardWidget({super.key, required this.missions});

  int get _completedCount => missions.where((m) => m.isCompleted).length;

  String get _progressLabel {
    if (missions.isEmpty) return '0%';
    return '${((_completedCount / missions.length) * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return PixelBorderContainer(
        width: double.infinity,
        pixelSize: 3,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'Weekly Mission!',
                style: AppPixelTypography.smallTitle.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'No missions this week',
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return PixelBorderContainer(
      width: double.infinity,
      pixelSize: 3,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                Text(
                  'Weekly Mission!',
                  style: AppPixelTypography.smallTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  _progressLabel,
                  style: AppTypography.titleSemiBold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...missions.map(
            (mission) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildMissionProgress(
                mission.detail,
                mission.isCompleted ? 1.0 : 0.0,
                mission.isCompleted ? 'Done' : '${mission.rewardXp} XP',
              ),
            ),
          ),
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
