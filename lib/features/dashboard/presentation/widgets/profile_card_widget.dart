import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';

class ProfileCardWidget extends StatelessWidget {
  final String fullName;
  final String roleLabel;
  final String email;
  final String location;
  final String bio;
  final int level;
  final int xp;
  final int nextXp;
  final double xpProgress;
  final int hours;
  final int streak;
  final int learningPathCount;
  final VoidCallback onSettingsTap;

  const ProfileCardWidget({
    super.key,
    required this.fullName,
    required this.roleLabel,
    required this.email,
    required this.location,
    required this.bio,
    required this.level,
    required this.xp,
    required this.nextXp,
    required this.xpProgress,
    required this.hours,
    required this.streak,
    required this.learningPathCount,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return PixelBorderContainer(
      pixelSize: 3,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondaryBrand, width: 2),
                ),
                child: Center(
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                    style: AppTypography.h3SemiBold.copyWith(
                      color: AppColors.secondaryBrand,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: AppTypography.titleSemiBold.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      roleLabel,
                      style: AppTypography.bodyRegular.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onSettingsTap,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.settings,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildMiniInfo('Email', email)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniInfo('Location', location)),
            ],
          ),
          const SizedBox(height: 8),
          _buildMiniInfo('Bio', bio),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Level Progress',
                style: AppTypography.bodySemiBold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Next: Level ${level + 1}',
                style: AppTypography.smallBodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: xpProgress,
            backgroundColor: AppColors.cardBorder,
            color: AppColors.secondaryBrand,
            minHeight: 8,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '$xp XP',
                style: AppTypography.smallBodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '$nextXp XP',
                style: AppTypography.smallBodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  title: '$hours Hours',
                  icon: Icons.access_time_filled,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatTile(
                  title: '8 Achievements',
                  icon: Icons.emoji_events,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  title: '$streak Days Streak',
                  icon: Icons.local_fire_department,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatTile(
                  title: '$learningPathCount Learning Path',
                  icon: Icons.menu_book,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.smallBodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.smallBodyRegular.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String title,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBrand,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.secondaryBrand),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySemiBold.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
