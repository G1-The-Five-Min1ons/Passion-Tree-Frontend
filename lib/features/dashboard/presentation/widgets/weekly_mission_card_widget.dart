import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/mission/data/models/user_mission_model.dart';

class WeeklyMissionCardWidget extends StatelessWidget {
  final List<UserMissionModel> missions;
  final ValueChanged<UserMissionModel>? onMissionTap;
  final VoidCallback? onEmptyTap;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const WeeklyMissionCardWidget({
    super.key,
    required this.missions,
    this.onMissionTap,
    this.onEmptyTap,
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
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 360).clamp(0.85, 1.4);

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
              padding: EdgeInsets.all(16 * scale),
              child: Row(
                children: [
                  SizedBox(
                    width: 16 * scale,
                    height: 16 * scale,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12 * scale),
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
              padding: EdgeInsets.all(8 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Failed to load missions',
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    errorMessage!,
                    style: AppTypography.smallBodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (onRetry != null) ...[
                    SizedBox(height: 8 * scale),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onEmptyTap,
                child: PixelBorderContainer(
                  pixelSize: 3,
                  padding: EdgeInsets.all(12 * scale),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'No missions this week',
                          style: AppTypography.bodyRegular.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (onEmptyTap != null) ...[
                        SizedBox(width: 8 * scale),
                        Text(
                          'Mission Center',
                          style: AppTypography.bodySemiBold.copyWith(
                            color: AppColors.secondaryBrand,
                          ),
                        ),
                        SizedBox(width: 4 * scale),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16 * scale,
                          color: AppColors.secondaryBrand,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          PixelBorderContainer(
            width: double.infinity,
            pixelSize: 3,
            padding: EdgeInsets.all(12 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: missions
                  .map(
                    (mission) => _buildMissionProgress(
                      mission: mission,
                      title: mission.detail,
                      value: mission.progress,
                      trailing: mission.isCompleted
                          ? 'Done'
                          : '${mission.rewardXp} XP',
                      useRecentActivityStyle: false,
                      scale: scale as double,
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
    double scale = 1.0,
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
              ? EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 7 * scale)
              : EdgeInsets.all(8 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.bodySemiBold.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    trailing,
                    style: AppTypography.smallBodySemiBold.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4 * scale),
              LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.cardBorder,
                color: AppColors.secondaryBrand,
                minHeight: 6 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}