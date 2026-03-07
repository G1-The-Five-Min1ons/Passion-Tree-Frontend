import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';

class AccountPreferencesSection extends StatefulWidget {
  const AccountPreferencesSection({super.key});

  @override
  State<AccountPreferencesSection> createState() =>
      _AccountPreferencesSectionState();
}

class _AccountPreferencesSectionState extends State<AccountPreferencesSection> {
  bool _twoFactor = false;
  bool _autoSave = true;

  @override
  Widget build(BuildContext context) {
    return PixelBorderContainer(
      pixelSize: 4,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Preferences',
            style: AppTypography.titleSemiBold.copyWith(color: AppColors.title),
          ),
          const SizedBox(height: 12),
          _buildToggleRow(
            title: 'Two-Factor Authentication',
            subtitle: 'Enhance your account security',
            value: _twoFactor,
            onChanged: (v) => setState(() => _twoFactor = v),
          ),
          const Divider(color: AppColors.cardBorder, height: 20),
          _buildToggleRow(
            title: 'Auto-Save progress',
            subtitle: 'Automatically save your progress',
            value: _autoSave,
            onChanged: (v) => setState(() => _autoSave = v),
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
