import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/mission/data/models/user_mission_model.dart';

class WeeklyMissionCardWidget extends StatelessWidget {
  final List<UserMissionModel> missions;
  final ValueChanged<UserMissionModel>? onMissionTap;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const WeeklyMissionCardWidget({
    super.key,
    required this.missions,
    this.onMissionTap,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
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
        if (isLoading && missions.isEmpty)
          SizedBox(
            width: double.infinity,
            child: PixelBorderContainer(
              pixelSize: 3,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading missions...',
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (errorMessage != null && missions.isEmpty)
          SizedBox(
            width: double.infinity,
            child: PixelBorderContainer(
              pixelSize: 3,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Failed to load missions',
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    errorMessage!,
                    style: AppTypography.smallBodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: onRetry,
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        else if (missions.isEmpty)
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
                    (mission) => _buildMissionProgress(
                      mission: mission,
                      title: mission.title,
                      value: mission.progress,
                      trailing: mission.isCompleted
                          ? 'Done'
                          : '${mission.rewardXp} XP',
                      useRecentActivityStyle: false,
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildMissionProgress({
    required UserMissionModel mission,
    required String title,
    required double value,
    required String trailing,
    required bool useRecentActivityStyle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onMissionTap == null ? null : () => onMissionTap!(mission),
        child: Container(
          margin: useRecentActivityStyle
              ? const EdgeInsets.only(bottom: 8)
              : EdgeInsets.zero,
          padding: useRecentActivityStyle
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 7)
              : const EdgeInsets.all(8),
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
