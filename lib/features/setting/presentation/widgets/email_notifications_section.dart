import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/setting/domain/usecases/get_settings_usecase.dart';
import 'package:passion_tree_frontend/features/setting/domain/usecases/update_setting_usecase.dart';

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
  static const String _platformKey = 'email_notify_platform_updates';
  static const String _weeklyKey = 'email_notify_weekly_progress';
  static const String _dailyKey = 'email_notify_daily_reminder';
  static const String _recommendationKey = 'email_notify_course_recommendations';
  static const String _commentsKey = 'email_notify_learning_path_comments';

  final GetSettingsUseCase _getSettingsUseCase = getIt<GetSettingsUseCase>();
  final UpdateSettingUseCase _updateSettingUseCase = getIt<UpdateSettingUseCase>();

  late Map<String, bool> _notifications;
  bool _isLoading = true;
  final Set<String> _updatingKeys = <String>{};

  static const Map<String, String> _settingKeyMap = {
    'platform': _platformKey,
    'weekly': _weeklyKey,
    'daily': _dailyKey,
    'recommendations': _recommendationKey,
    'comments': _commentsKey,
  };

  @override
  void initState() {
    super.initState();
    _notifications = {
      'platform': true,
      'weekly': true,
      'daily': true,
      'recommendations': true,
      'comments': true,
    };
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    setState(() => _isLoading = true);

    final result = await _getSettingsUseCase.execute();
    if (!mounted) return;

    result.fold(
      (failure) {
        LogHandler.warning(
          'SETTING UI · EMAIL NOTIFICATIONS load fallback to defaults: ${failure.message}',
        );
        setState(() => _isLoading = false);
      },
      (settings) {
        final map = {for (final s in settings) s.key: s.value};
        setState(() {
          _notifications = {
            for (final entry in _notifications.entries)
              entry.key:
                  (map[_settingKeyMap[entry.key] ?? '']?.toLowerCase() == 'true')
                      ? true
                      : (map.containsKey(_settingKeyMap[entry.key])
                            ? false
                            : entry.value),
          };
          _isLoading = false;
        });
      },
    );
  }

  List<NotificationPreference> get _notificationItems => [
    NotificationPreference(
      title: 'Platform updates',
      subtitle:
          'Get notified when new features, improvements, or important announcements are released.',
      value: _notifications['platform'] ?? false,
    ),
    NotificationPreference(
      title: 'My weekly progress report is ready',
      subtitle:
          'Receive a summary of your weekly performance and progress directly to your inbox.',
      value: _notifications['weekly'] ?? false,
    ),
    NotificationPreference(
      title: 'Daily reminders when I forgot to practice',
      subtitle:
          "Stay on track – get a gentle reminder if you miss your daily practice session.",
      value: _notifications['daily'] ?? false,
    ),
    NotificationPreference(
      title: 'Course recommendations for me',
      subtitle:
          'Get personalized course suggestions based on your goals and recent activity.',
      value: _notifications['recommendations'] ?? false,
    ),
    NotificationPreference(
      title: 'New comments on my learning paths',
      subtitle:
          'Receive alerts when learners leave comments or questions on your learning paths.',
      value: _notifications['comments'] ?? false,
    ),
  ];

  Future<void> _updateNotification(int index, bool value) async {
    final key = _notifications.keys.elementAt(index);
    final settingKey = _settingKeyMap[key];
    if (settingKey == null) return;

    final previous = _notifications[key] ?? false;
    setState(() {
      _notifications[key] = value;
      _updatingKeys.add(key);
    });

    final result = await _updateSettingUseCase.execute(
      key: settingKey,
      value: value.toString(),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        LogHandler.error(
          'SETTING UI · EMAIL NOTIFICATIONS update failed key=$settingKey: ${failure.message}',
        );
        setState(() {
          _notifications[key] = previous;
          _updatingKeys.remove(key);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update notification: ${failure.message}')),
        );
      },
      (_) {
        setState(() {
          _updatingKeys.remove(key);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Notifications',
          style: AppTypography.titleSemiBold.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [..._buildNotificationsList()],
                ),
        ),
      ],
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
          keyName: _notifications.keys.elementAt(i),
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
    required String keyName,
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
          onChanged: _updatingKeys.contains(keyName) ? null : onChanged,
          activeThumbColor: AppColors.primaryBrand,
          activeTrackColor: AppColors.primaryBrand.withValues(alpha: 0.4),
          inactiveThumbColor: AppColors.textDisabled,
          inactiveTrackColor: AppColors.cardBorder,
        ),
      ],
    );
  }
}
