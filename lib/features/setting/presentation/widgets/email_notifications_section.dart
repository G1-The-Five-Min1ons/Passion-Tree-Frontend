import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';

class EmailNotificationsSection extends StatefulWidget {
  const EmailNotificationsSection({super.key});

  @override
  State<EmailNotificationsSection> createState() =>
      _EmailNotificationsSectionState();
}

class _EmailNotificationsSectionState extends State<EmailNotificationsSection> {
  bool _notifyPlatform = true;
  bool _notifyWeekly = true;
  bool _notifyDaily = true;
  bool _notifyCourseRecommendations = true;
  bool _notifyPathComments = true;
  bool _notifyWebPush = false;

  @override
  Widget build(BuildContext context) {
    return PixelBorderContainer(
      pixelSize: 4,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email Notifications',
            style: AppTypography.titleSemiBold.copyWith(color: AppColors.title),
          ),
          const SizedBox(height: 12),
          _buildToggleRow(
            title: 'Platform updates',
            subtitle:
                'Get notified when new features, improvements, or important announcements are released.',
            value: _notifyPlatform,
            onChanged: (v) => setState(() => _notifyPlatform = v),
          ),
          const Divider(color: AppColors.cardBorder, height: 20),
          _buildToggleRow(
            title: 'My weekly progress report is ready',
            subtitle:
                'Receive a summary of your weekly performance and progress directly to your inbox.',
            value: _notifyWeekly,
            onChanged: (v) => setState(() => _notifyWeekly = v),
          ),
          const Divider(color: AppColors.cardBorder, height: 20),
          _buildToggleRow(
            title: 'Daily reminders when I forgot to practice',
            subtitle:
                "Stay on track – get a gentle reminder if you miss your daily practice session.",
            value: _notifyDaily,
            onChanged: (v) => setState(() => _notifyDaily = v),
          ),
          const Divider(color: AppColors.cardBorder, height: 20),
          _buildToggleRow(
            title: 'Course recommendations for me',
            subtitle:
                'Get personalized course suggestions based on your goals and recent activity.',
            value: _notifyCourseRecommendations,
            onChanged: (v) => setState(() => _notifyCourseRecommendations = v),
          ),
          const Divider(color: AppColors.cardBorder, height: 20),
          _buildToggleRow(
            title: 'New comments on my learning paths',
            subtitle:
                'Receive alerts when learners leave comments or questions on your learning paths.',
            value: _notifyPathComments,
            onChanged: (v) => setState(() => _notifyPathComments = v),
          ),
          const Divider(color: AppColors.cardBorder, height: 20),
          _buildToggleRow(
            title: 'Enable web push notifications',
            subtitle:
                "Receive instant notifications from your browser, even when the website isn't open.",
            value: _notifyWebPush,
            onChanged: (v) => setState(() => _notifyWebPush = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.subtitleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.smallBodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primaryBrand,
          activeTrackColor: AppColors.primaryBrand.withValues(alpha: 0.4),
          inactiveThumbColor: AppColors.textDisabled,
          inactiveTrackColor: AppColors.cardBorder,
        ),
      ],
    );
  }
}
