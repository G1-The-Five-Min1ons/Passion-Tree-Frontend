import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';

class NotificationPreference {
  final String title;
  final String subtitle;
  final bool value;

  NotificationPreference({
    required this.title,
    required this.subtitle,
    required this.value,
  });
}

class EmailNotificationsSection extends StatefulWidget {
  const EmailNotificationsSection({super.key});

  @override
  State<EmailNotificationsSection> createState() =>
      _EmailNotificationsSectionState();
}

class _EmailNotificationsSectionState extends State<EmailNotificationsSection> {
  late Map<String, bool> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = {
      'platform': true,
      'weekly': true,
      'daily': true,
      'recommendations': true,
      'comments': true,
      'webPush': false,
    };
  }

  List<NotificationPreference> get _notificationItems => [
        NotificationPreference(
          title: 'Platform updates',
          subtitle:
              'Get notified when new features, improvements, or important announcements are released.',
          value: _notifications['platform']!,
        ),
        NotificationPreference(
          title: 'My weekly progress report is ready',
          subtitle:
              'Receive a summary of your weekly performance and progress directly to your inbox.',
          value: _notifications['weekly']!,
        ),
        NotificationPreference(
          title: 'Daily reminders when I forgot to practice',
          subtitle:
              "Stay on track – get a gentle reminder if you miss your daily practice session.",
          value: _notifications['daily']!,
        ),
        NotificationPreference(
          title: 'Course recommendations for me',
          subtitle:
              'Get personalized course suggestions based on your goals and recent activity.',
          value: _notifications['recommendations']!,
        ),
        NotificationPreference(
          title: 'New comments on my learning paths',
          subtitle:
              'Receive alerts when learners leave comments or questions on your learning paths.',
          value: _notifications['comments']!,
        ),
        NotificationPreference(
          title: 'Enable web push notifications',
          subtitle:
              "Receive instant notifications from your browser, even when the website isn't open.",
          value: _notifications['webPush']!,
        ),
      ];

  void _updateNotification(int index, bool value) {
    final key = _notifications.keys.elementAt(index);
    setState(() => _notifications[key] = value);
  }

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
          ..._buildNotificationsList(),
        ],
      ),
    );
  }

  List<Widget> _buildNotificationsList() {
    final items = <Widget>[];
    final notifications = _notificationItems;

    for (var i = 0; i < notifications.length; i++) {
      if (i > 0) {
        items.add(const Divider(color: AppColors.cardBorder, height: 20));
      }

      items.add(
        _buildToggleRow(
          title: notifications[i].title,
          subtitle: notifications[i].subtitle,
          value: notifications[i].value,
          onChanged: (v) => _updateNotification(i, v),
        ),
      );
    }

    return items;
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
