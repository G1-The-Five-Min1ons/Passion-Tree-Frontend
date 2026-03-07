import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/user_profile.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/setting/presentation/pages/teacher_verification_page.dart';

class AccountPreferencesSection extends StatefulWidget {
  const AccountPreferencesSection({super.key});

  @override
  State<AccountPreferencesSection> createState() =>
      _AccountPreferencesSectionState();
}

class _AccountPreferencesSectionState extends State<AccountPreferencesSection> {
  final IAuthRepository _authRepository = getIt<IAuthRepository>();

  bool _autoSave = true;
  bool _isLoading = true;
  bool _isSavingPhone = false;
  String _role = '';
  UserProfile? _userProfile;

  final TextEditingController _phoneController = TextEditingController();

  bool get _isTeacher => _role.toLowerCase() == 'teacher';

  @override
  void initState() {
    super.initState();
    _loadPreferenceData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferenceData() async {
    try {
      final profile = await _authRepository.getProfile();
      final role = await _authRepository.getUserRole();

      if (!mounted) return;
      setState(() {
        _userProfile = profile;
        _role = (role == null || role.trim().isEmpty)
            ? profile.user.role
            : role;
        _phoneController.text = profile.profile?.phoneNumber ?? '';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openTeacherVerification() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TeacherVerificationPage()),
    );
  }

  Future<void> _saveStudentPhone() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number.')),
      );
      return;
    }

    if (!RegExp(r'^[0-9+]{9,15}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number format is invalid.')),
      );
      return;
    }

    final profile = _userProfile ?? await _authRepository.getProfile();

    setState(() => _isSavingPhone = true);
    try {
      await _authRepository.updateAccountSettings(
        username: profile.user.username,
        firstName: profile.user.firstName,
        lastName: profile.user.lastName,
        location: profile.profile?.location ?? '',
        bio: profile.profile?.bio ?? '',
        avatarUrl: profile.profile?.avatarUrl,
        phoneNumber: phone,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update phone number: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingPhone = false);
      }
    }
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
            'Account Preferences',
            style: AppTypography.titleSemiBold.copyWith(color: AppColors.title),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_isTeacher)
            _buildActionRow(
              title: 'Verify Teacher Account',
              subtitle:
                  'Bind phone number, reason to teach, and teaching history.',
              onTap: _openTeacherVerification,
            )
          else
            _buildStudentPhoneRow(),
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

  Widget _buildActionRow({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
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
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentPhoneRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: AppTypography.subtitleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Bind your phone number to verify your account.',
          style: AppTypography.smallBodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. 0812345678',
                  hintStyle: AppTypography.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryBrand),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 44,
              width: 44,
              child: ElevatedButton(
                onPressed: _isSavingPhone ? null : _saveStudentPhone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrand,
                  foregroundColor: AppColors.background,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSavingPhone
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check, size: 18),
              ),
            ),
          ],
        ),
      ],
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
