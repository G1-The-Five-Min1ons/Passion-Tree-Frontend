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
  final int achievements;
  final String avatarUrl;
  final String rankName;
  final String memberSince;
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
    this.achievements = 0,
    this.avatarUrl = '',
    this.rankName = 'Beginner',
    this.memberSince = '',
  });

  @override
  Widget build(BuildContext context) {
    return PixelBorderContainer(
      pixelSize: 3,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header: Avatar + Name + Settings ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildAvatar(),
                  Positioned(
                    bottom: -4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBrand,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Lv.$level',
                          style: AppTypography.smallBodySemiBold.copyWith(
                            color: AppColors.background,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleLabel,
                      style: AppTypography.bodyRegular.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (memberSince.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        'Member since $memberSince',
                        style: AppTypography.smallBodyRegular.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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

          const SizedBox(height: 12),

          // --- Email & Location side by side ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildMiniInfo('Email', email)),
              const SizedBox(width: 12),
              Expanded(child: _buildMiniInfo('Location', location)),
            ],
          ),

          const SizedBox(height: 6),
          _buildMiniInfo('Bio', bio),

          const SizedBox(height: 14),

          // --- Level Progress ---
          Row(
            children: [
              Text(
                'Level $level',
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
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: xpProgress,
              backgroundColor: AppColors.cardBorder,
              color: AppColors.secondaryBrand,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '$xp XP',
                style: AppTypography.smallBodySemiBold.copyWith(
                  color: AppColors.secondaryBrand,
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

          const SizedBox(height: 12),

          // --- Stats Grid ---
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  value: '$hours',
                  label: 'Hours',
                  icon: Icons.access_time_filled,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatTile(
                  value: '$achievements',
                  label: 'Achievements',
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
                  value: '$streak',
                  label: 'Days Streak',
                  icon: Icons.local_fire_department,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatTile(
                  value: '$learningPathCount',
                  label: 'Learning Path',
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
          value.isEmpty ? '-' : value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.smallBodyRegular.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final hasAvatar = avatarUrl.trim().isNotEmpty;

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.primaryBrand.withValues(alpha: 0.35),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.secondaryBrand, width: 2),
      ),
      child: ClipOval(
        child: hasAvatar
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildAvatarFallback(),
              )
            : _buildAvatarFallback(),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Text(
        fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
        style: AppTypography.h3SemiBold.copyWith(
          color: AppColors.secondaryBrand,
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.secondaryBrand),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppTypography.subtitleSemiBold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const WidgetSpan(
                    child: SizedBox(width: 6),
                  ),
                  TextSpan(
                    text: label,
                    style: AppTypography.smallBodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
