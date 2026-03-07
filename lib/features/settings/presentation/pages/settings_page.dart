import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/settings/presentation/widgets/account_settings_section.dart';
import 'package:passion_tree_frontend/features/settings/presentation/widgets/account_preferences_section.dart';
import 'package:passion_tree_frontend/features/settings/presentation/widgets/region_section.dart';
import 'package:passion_tree_frontend/features/settings/presentation/widgets/email_notifications_section.dart';
import 'package:passion_tree_frontend/features/settings/presentation/widgets/danger_zone_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarWidget(
        title: 'Account Settings',
        showBackButton: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AccountSettingsSection(),
            SizedBox(height: 20),
            AccountPreferencesSection(),
            SizedBox(height: 20),
            RegionSection(),
            SizedBox(height: 20),
            EmailNotificationsSection(),
            SizedBox(height: 20),
            DangerZoneSection(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
