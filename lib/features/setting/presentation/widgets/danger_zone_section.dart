import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/login_page.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/user_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/user_event.dart';

class DangerZoneSection extends StatelessWidget {
  const DangerZoneSection({super.key});

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTypography.h3SemiBold.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      variant: AppButtonVariant.text,
                      text: 'Cancel',
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      variant: AppButtonVariant.text,
                      text: confirmLabel,
                      backgroundColor: confirmColor,
                      onPressed: () => Navigator.of(ctx).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignOutAll(BuildContext context) async {
    final confirm = await _showConfirmDialog(
      context,
      title: 'Sign out all devices',
      message:
          'This will revoke all active sessions and tokens. You will be signed out everywhere.',
      confirmLabel: 'Sign out all',
      confirmColor: AppColors.cancel,
    );
    if (confirm == true && context.mounted) {
      context.read<UserBloc>().add(const ClearUser());
      await getIt<IAuthRepository>().clearAuth();
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  Future<void> _handleDeactivate(BuildContext context) async {
    await _showConfirmDialog(
      context,
      title: 'Deactivate account',
      message:
          'Temporarily disable your account. It can be reactivated within 14 days.',
      confirmLabel: 'Deactivate',
      confirmColor: AppColors.warning,
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    await _showConfirmDialog(
      context,
      title: 'Delete account',
      message:
          'Permanently delete your account and all data. This cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: AppColors.cancel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: AppTypography.titleSemiBold.copyWith(color: AppColors.cancel),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cancel, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: AppColors.cardBorder, height: 20),
              _buildDangerRow(
                title: 'Sign out all devices',
                subtitle: 'Revoke all active sessions and tokens',
                buttonLabel: 'sign-out all',
                buttonColor: AppColors.surface,
                onTap: () => _handleSignOutAll(context),
              ),
              const Divider(color: AppColors.cardBorder, height: 20),
              _buildDangerRow(
                title: 'Deactivate account',
                subtitle:
                    'Temporarily disable your account (can be reactivated within 14 days)',
                buttonLabel: 'Deactivate',
                buttonColor: AppColors.surface,
                onTap: () => _handleDeactivate(context),
              ),
              const Divider(color: AppColors.cardBorder, height: 20),
              _buildDangerRow(
                title: 'Delete account',
                subtitle: 'Permanently delete your account and all data',
                buttonLabel: 'Delete',
                buttonColor: AppColors.cancel,
                onTap: () => _handleDelete(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerRow({
    required String title,
    required String subtitle,
    required String buttonLabel,
    required Color buttonColor,
    required VoidCallback onTap,
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
                  color: AppColors.cancel,
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
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: AppColors.buttonBorder, width: 1),
            ),
            textStyle: AppTypography.smallBodyMedium,
          ),
          child: Text(buttonLabel),
        ),
      ],
    );
  }
}
