import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/services/home_tab_navigation_notifier.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/mission/data/models/user_mission_model.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';

class MissionCenterPage extends StatelessWidget {
  const MissionCenterPage({
    super.key,
    required this.missions,
    this.highlightedMissionId,
  });

  final List<UserMissionModel> missions;
  final String? highlightedMissionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const AppBarWidget(title: 'Mission Center', showBackButton: true),
      body: missions.isEmpty
          ? Center(
              child: Text(
                'No missions available',
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: missions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final mission = missions[index];
                return _MissionTile(
                  mission: mission,
                  highlighted: mission.missionId == highlightedMissionId,
                );
              },
            ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({required this.mission, required this.highlighted});

  final UserMissionModel mission;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final statusText = mission.isCompleted ? 'Completed' : 'In progress';
    final expireText = mission.expireAt == null
        ? 'No deadline'
        : 'Due ${mission.expireAt!.day}/${mission.expireAt!.month}/${mission.expireAt!.year}';
    final progressText = mission.targetValue > 0
        ? '${mission.currentValue}/${mission.targetValue}'
        : null;

    return PixelBorderContainer(
      width: double.infinity,
      pixelSize: 3,
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          border: highlighted
              ? Border.all(color: AppColors.cardBorder, width: 1.5)
              : null,
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mission.detail,
                    style: AppTypography.bodySemiBold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${mission.rewardXp} XP',
                  style: AppTypography.smallBodySemiBold.copyWith(
                    color: AppColors.secondaryBrand,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    statusText,
                    style: AppTypography.smallBodyRegular.copyWith(
                      color: mission.isCompleted
                          ? AppColors.secondaryBrand
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (progressText != null)
                  Text(
                    progressText,
                    style: AppTypography.smallBodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: mission.progress,
              backgroundColor: AppColors.cardBorder,
              color: AppColors.secondaryBrand,
              minHeight: 6,
            ),
            const SizedBox(height: 6),
            Text(
              expireText,
              style: AppTypography.smallBodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: AppButton(
                variant: AppButtonVariant.text,
                text: mission.isCompleted ? 'Completed' : 'Go to Learn',
                onPressed: mission.isCompleted
                    ? null
                    : () {
                        Navigator.pop(context);
                        HomeTabNavigationNotifier.jumpToTab(1);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
