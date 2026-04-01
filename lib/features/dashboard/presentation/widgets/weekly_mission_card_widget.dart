import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';

class WeeklyMissionCardWidget extends StatelessWidget {
  final List<MissionItem> missions;
  final ValueChanged<MissionItem>? onMissionTap;

  const WeeklyMissionCardWidget({
    super.key,
    required this.missions,
    this.onMissionTap,
  });

  int get _completedCount => missions.where((m) => m.isCompleted).length;

  int get _overallPercent {
    if (missions.isEmpty) return 0;
    return ((_completedCount / missions.length) * 100).round();
  }

  int get _daysRemaining {
    final expiring = missions
        .where((m) => m.expireAt != null)
        .map((m) => m.expireAt!)
        .toList();
    if (expiring.isEmpty) return 0;
    expiring.sort();
    final diff = expiring.first.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Weekly Mission',
              style: AppPixelTypography.smallTitle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (missions.isNotEmpty) ...[
              Text(
                '$_overallPercent%',
                style: AppTypography.bodySemiBold.copyWith(
                  color: AppColors.secondaryBrand,
                ),
              ),
              const SizedBox(width: 8),
              if (_daysRemaining > 0)
                Text(
                  '$_daysRemaining days left',
                  style: AppTypography.smallBodyRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (missions.isEmpty)
          SizedBox(
            width: double.infinity,
            child: PixelBorderContainer(
              pixelSize: 3,
              padding: const EdgeInsets.all(12),
              child: Text(
                'No missions this week',
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          PixelBorderContainer(
            width: double.infinity,
            pixelSize: 3,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: missions
                  .map(
                    (mission) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildMissionProgress(
                        mission: mission,
                        title: mission.detail,
                        value: mission.isCompleted ? 1.0 : 0.0,
                        trailing: mission.isCompleted
                            ? 'Done'
                            : '${mission.rewardXp} XP',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildMissionProgress({
    required MissionItem mission,
    required String title,
    required double value,
    required String trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onMissionTap == null ? null : () => onMissionTap!(mission),
        child: Container(
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
        ),
      ),
    );
  }
}
