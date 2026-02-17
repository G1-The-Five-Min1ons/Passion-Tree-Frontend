import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/login_page.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = '';
  String _role = '';
  String _userId = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authRepo = getIt<IAuthRepository>();
    final username = await authRepo.getUsername() ?? 'User';
    final role = await authRepo.getUserRole() ?? 'student';
    final userId = await authRepo.getUserId() ?? '';

    if (!mounted) return;
    setState(() {
      _username = username;
      _role = role;
      _userId = userId;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Logout',
                style: AppPixelTypography.h3.copyWith(
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to logout?',
                style: AppTypography.bodySemiBold.copyWith(
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
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      variant: AppButtonVariant.text,
                      text: 'Logout',
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      LogHandler.separator(title: 'AUTH · LOGOUT');
      await getIt<IAuthRepository>().clearAuth();
      LogHandler.success('User logged out — tokens cleared');

      if (!mounted) return;

      // Navigate to LoginPage and clear entire navigation stack
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarWidget(
        title: 'Profile',
        showBackButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrand.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondaryBrand,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _username.isNotEmpty
                            ? _username[0].toUpperCase()
                            : '?',
                        style: AppPixelTypography.h1.copyWith(
                          color: AppColors.secondaryBrand,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Username
                  Text(
                    _username,
                    style: AppPixelTypography.h3.copyWith(
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _role == 'teacher'
                          ? AppColors.secondaryBrand.withValues(alpha: 0.2)
                          : AppColors.primaryBrand.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _role == 'teacher'
                            ? AppColors.secondaryBrand
                            : AppColors.primaryBrand,
                      ),
                    ),
                    child: Text(
                      _role == 'teacher' ? 'Teacher' : 'Student',
                      style: AppTypography.subtitleMedium.copyWith(
                        color: _role == 'teacher'
                            ? AppColors.secondaryBrand
                            : AppColors.iconbar,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Info card
                  PixelBorderContainer(
                    pixelSize: 4,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoRow('Username', _username),
                        const Divider(color: AppColors.textSecondary, height: 24),
                        _buildInfoRow('Role', _role == 'teacher' ? 'Teacher' : 'Student'),
                        if (_userId.isNotEmpty) ...[
                          const Divider(color: AppColors.textSecondary, height: 24),
                          _buildInfoRow('User ID', _userId.substring(0, 8) + '...'),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      variant: AppButtonVariant.text,
                      text: 'Logout',
                      onPressed: _handleLogout,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.subtitleMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTypography.bodySemiBold.copyWith(
              color: AppColors.surface,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
