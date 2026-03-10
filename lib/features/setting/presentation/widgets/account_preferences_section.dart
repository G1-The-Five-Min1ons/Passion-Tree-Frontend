import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/user_profile.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_profile_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_user_role_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/update_account_settings_usecase.dart';
import 'package:passion_tree_frontend/features/setting/domain/usecases/get_settings_usecase.dart';
import 'package:passion_tree_frontend/features/setting/domain/usecases/update_setting_usecase.dart';
import 'package:passion_tree_frontend/features/setting/presentation/pages/teacher_verification_page.dart';

class AccountPreferencesSection extends StatefulWidget {
  const AccountPreferencesSection({super.key});

  @override
  State<AccountPreferencesSection> createState() =>
      _AccountPreferencesSectionState();
}

class _AccountPreferencesSectionState extends State<AccountPreferencesSection> {
  static const String _autoSaveKey = 'auto_save_progress';

  final GetProfileUseCase _getProfileUseCase = getIt<GetProfileUseCase>();
  final GetUserRoleUseCase _getUserRoleUseCase = getIt<GetUserRoleUseCase>();
  final UpdateAccountSettingsUseCase _updateAccountSettingsUseCase =
      getIt<UpdateAccountSettingsUseCase>();
  final GetSettingsUseCase _getSettingsUseCase = getIt<GetSettingsUseCase>();
  final UpdateSettingUseCase _updateSettingUseCase =
      getIt<UpdateSettingUseCase>();

  bool _autoSave = true;
  bool _isLoading = true;
  bool _isSavingPhone = false;
  bool _isSavingAutoSave = false;
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
    LogHandler.info('SETTING UI · LOAD PREFERENCES');

    final profileResult = await _getProfileUseCase.execute();
    final roleResult = await _getUserRoleUseCase.execute();
    final settingsResult = await _getSettingsUseCase.execute();

    if (!mounted) return;

    profileResult.fold(
      (failure) {
        LogHandler.error('SETTING UI · LOAD failed profile: ${failure.message}');
        setState(() => _isLoading = false);
      },
      (profile) {
        final role = roleResult.fold(
          (failure) => profile.user.role,
          (role) =>
              (role == null || role.trim().isEmpty) ? profile.user.role : role,
        );

        setState(() {
          _userProfile = profile;
          _role = role;
          _phoneController.text = profile.profile?.phoneNumber ?? '';

          settingsResult.fold(
            (failure) {
              LogHandler.warning(
                'SETTING UI · LOAD settings fallback to default auto-save=true: ${failure.message}',
              );
              _autoSave = true;
            },
            (settings) {
              final autoSaveSetting = settings.where((item) => item.key == _autoSaveKey);
              if (autoSaveSetting.isEmpty) {
                _autoSave = true;
              } else {
                _autoSave = autoSaveSetting.first.value.toLowerCase() == 'true';
              }

              LogHandler.info(
                'SETTING UI · LOAD resolved auto-save=$_autoSave from settingsCount=${settings.length}',
              );
            },
          );

          _isLoading = false;
        });
      },
    );
  }

  Future<void> _onAutoSaveChanged(bool value) async {
    LogHandler.info('SETTING UI · TOGGLE request: value=$value');

    setState(() {
      _autoSave = value;
      _isSavingAutoSave = true;
    });

    final result = await _updateSettingUseCase.execute(
      key: _autoSaveKey,
      value: value.toString(),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _autoSave = !value;
          _isSavingAutoSave = false;
        });
        LogHandler.error('SETTING UI · TOGGLE failed: ${failure.message}');
        _showErrorMessage('Failed to update auto-save: ${failure.message}');
      },
      (_) {
        setState(() {
          _isSavingAutoSave = false;
        });
        LogHandler.success('SETTING UI · TOGGLE success: value=$value');
      },
    );
  }

  Future<void> _openTeacherVerification() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TeacherVerificationPage()),
    );
  }

  Future<void> _saveStudentPhone() async {
    final phone = _phoneController.text.trim();

    // Retrieve profile safely: avoid force-unwrapping before null checks.
    UserProfile? profile = _userProfile;
    if (profile == null) {
      final profileResult = await _getProfileUseCase.execute();
      var failed = false;
      profileResult.fold((failure) {
        _showErrorMessage('Failed to load profile: ${failure.message}');
        failed = true;
      }, (loadedProfile) => profile = loadedProfile);

      if (failed || profile == null) return;
    }

    final resolvedProfile = profile;
    if (resolvedProfile == null) return;

    setState(() => _isSavingPhone = true);

    final result = await _updateAccountSettingsUseCase.execute(
      username: resolvedProfile.user.username,
      firstName: resolvedProfile.user.firstName,
      lastName: resolvedProfile.user.lastName,
      location: resolvedProfile.profile?.location,
      bio: resolvedProfile.profile?.bio,
      avatarUrl: resolvedProfile.profile?.avatarUrl,
      phoneNumber: phone,
    );

    if (!mounted) return;

    setState(() => _isSavingPhone = false);

    result.fold(
      (failure) => _showErrorMessage(failure.message),
      (_) => _showSuccessMessage('Phone number updated successfully.'),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Preferences',
          style: AppTypography.titleSemiBold.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                onChanged: _isSavingAutoSave ? null : _onAutoSaveChanged,
              ),
            ],
          ),
        ),
      ],
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
    required ValueChanged<bool>? onChanged,
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
