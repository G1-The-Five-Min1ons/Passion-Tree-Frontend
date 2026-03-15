import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
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

  void _showResultSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.cancel : AppColors.status,
      ),
    );
  }

  String _friendlyErrorMessage(Object error) {
    final raw = error.toString();
    final cleaned = raw
        .replaceFirst('Exception: ', '')
        .replaceFirst('AuthException: ', '')
        .trim();
    return cleaned.isEmpty ? 'Something went wrong. Please try again.' : cleaned;
  }

  Future<String?> _showPasswordConfirmDialog(BuildContext context) {
    final passwordController = TextEditingController();
    String? errorText;

    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: PixelBorderContainer(
            pixelSize: 4,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirm password',
                  style: AppTypography.h3SemiBold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your password to permanently delete this account.',
                  style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    errorText: errorText,
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.buttonBorder),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        variant: AppButtonVariant.text,
                        text: 'Cancel',
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        variant: AppButtonVariant.text,
                        text: 'Delete',
                        backgroundColor: AppColors.cancel,
                        onPressed: () {
                          final password = passwordController.text.trim();
                          if (password.isEmpty) {
                            setState(() {
                              errorText = 'Password is required';
                            });
                            return;
                          }
                          Navigator.of(ctx).pop(password);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
    LogHandler.info('DangerZone: Sign out all tapped');
    final confirm = await _showConfirmDialog(
      context,
      title: 'Sign out all devices',
      message:
          'This will revoke all active sessions and tokens. You will be signed out everywhere.',
      confirmLabel: 'Sign out all',
      confirmColor: AppColors.cancel,
    );
    if (confirm != true) {
      LogHandler.info('DangerZone: Sign out all cancelled by user');
      return;
    }
    if (confirm == true && context.mounted) {
      try {
        LogHandler.info('DangerZone: Executing sign out all request');
        await getIt<IAuthRepository>().logout();
        if (!context.mounted) return;
        LogHandler.success('DangerZone: Sign out all completed');
        _showResultSnackBar(
          context,
          'Signed out from all devices successfully.',
        );
        context.read<UserBloc>().add(const ClearUser());
        await Future.delayed(const Duration(milliseconds: 600));
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      } catch (e) {
        if (!context.mounted) return;
        LogHandler.error('DangerZone: Sign out all failed', error: e);
        _showResultSnackBar(
          context,
          _friendlyErrorMessage(e),
          isError: true,
        );
      }
    }
  }

  Future<void> _handleDeactivate(BuildContext context) async {
    LogHandler.info('DangerZone: Deactivate tapped');
    final confirm = await _showConfirmDialog(
      context,
      title: 'Deactivate account',
      message:
          'Temporarily disable your account. It can be reactivated within 14 days.',
      confirmLabel: 'Deactivate',
      confirmColor: AppColors.warning,
    );
    if (confirm != true) {
      LogHandler.info('DangerZone: Deactivate cancelled by user');
      return;
    }
    if (!context.mounted) return;

    try {
      LogHandler.info('DangerZone: Executing deactivate request');
      await getIt<IAuthRepository>().deactivateAccount();
      if (!context.mounted) return;
      LogHandler.success('DangerZone: Deactivate completed');
      _showResultSnackBar(
        context,
        'Account deactivated. You can reactivate within 14 days by logging in again.',
      );
      context.read<UserBloc>().add(const ClearUser());
      await Future.delayed(const Duration(milliseconds: 600));
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      LogHandler.error('DangerZone: Deactivate failed', error: e);
      _showResultSnackBar(
        context,
        _friendlyErrorMessage(e),
        isError: true,
      );
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    LogHandler.info('DangerZone: Delete tapped');
    final confirm = await _showConfirmDialog(
      context,
      title: 'Delete account',
      message:
          'Permanently delete your account and all data. This cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: AppColors.cancel,
    );
    if (confirm != true) {
      LogHandler.info('DangerZone: Delete cancelled at first confirmation');
      return;
    }
    if (!context.mounted) return;

    final password = await _showPasswordConfirmDialog(context);
    if (password == null || password.isEmpty) {
      LogHandler.info('DangerZone: Delete cancelled at password confirmation');
      return;
    }
    if (!context.mounted) return;

    try {
      LogHandler.info('DangerZone: Executing delete account request');
      await getIt<IAuthRepository>().deleteUser(password);
      if (!context.mounted) return;
      LogHandler.success('DangerZone: Delete account completed');
      _showResultSnackBar(
        context,
        'Account deleted successfully.',
      );
      context.read<UserBloc>().add(const ClearUser());
      await Future.delayed(const Duration(milliseconds: 600));
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      LogHandler.error('DangerZone: Delete account failed', error: e);
      _showResultSnackBar(
        context,
        _friendlyErrorMessage(e),
        isError: true,
      );
    }
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
