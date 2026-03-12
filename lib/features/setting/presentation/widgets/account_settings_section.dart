import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/core/services/upload_service.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_profile_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/update_account_settings_usecase.dart';

class AccountSettingsSection extends StatefulWidget {
  const AccountSettingsSection({super.key});

  @override
  State<AccountSettingsSection> createState() => _AccountSettingsSectionState();
}

class _AccountSettingsSectionState extends State<AccountSettingsSection> {
  // Profile data
  String _firstName = '';
  String _lastName = '';
  String _username = '';
  String _location = '';
  String _bio = '';
  String _email = '';
  String _avatarUrl = '';

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  final GetProfileUseCase _getProfileUseCase = getIt<GetProfileUseCase>();
  final UpdateAccountSettingsUseCase _updateAccountSettingsUseCase =
      getIt<UpdateAccountSettingsUseCase>();
  final UploadApiService _uploadService = getIt<UploadApiService>();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedAvatarFile;

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: _firstName);
    _lastNameCtrl = TextEditingController(text: _lastName);
    _usernameCtrl = TextEditingController(text: _username);
    _locationCtrl = TextEditingController(text: _location);
    _bioCtrl = TextEditingController(text: _bio);
    _emailCtrl = TextEditingController(text: _email);

    _loadAccountSettings();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _locationCtrl.dispose();
    _bioCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAccountSettings() async {
    LogHandler.separator(title: 'SETTINGS · LOAD ACCOUNT');
    
    final result = await _getProfileUseCase.execute();

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        LogHandler.error('Failed to load account settings: ${failure.message}');
      },
      (userProfile) {
        setState(() {
          _firstName = userProfile.user.firstName;
          _lastName = userProfile.user.lastName;
          _username = userProfile.user.username;
          _email = userProfile.user.email;
          _location = userProfile.profile?.location ?? '';
          _bio = userProfile.profile?.bio ?? '';
          _avatarUrl = userProfile.profile?.avatarUrl ?? '';

          _firstNameCtrl.text = _firstName;
          _lastNameCtrl.text = _lastName;
          _usernameCtrl.text = _username;
          _emailCtrl.text = _email;
          _locationCtrl.text = _location;
          _bioCtrl.text = _bio;

          _isLoading = false;
        });

        LogHandler.info('Account settings loaded from backend');
        LogHandler.success('SETTINGS · LOAD ACCOUNT completed');
      },
    );
  }

  Future<void> _save() async {
    LogHandler.separator(title: 'SETTINGS · SAVE ACCOUNT');
    setState(() => _isSaving = true);

    try {
      String? uploadedAvatarUrl;
      if (_selectedAvatarFile != null) {
        LogHandler.info('SETTINGS · Uploading new avatar image');
        final imageFile = _selectedAvatarFile!;
        final fileName = imageFile.path.split(RegExp(r'[/\\]')).last;
        final urls = await _uploadService.getPresignedUrl(fileName, 'profile');
        await _uploadService.uploadFileToBlob(
          urls['upload_url']!,
          await imageFile.readAsBytes(),
          fileName,
        );
        uploadedAvatarUrl = urls['public_url'];
        LogHandler.success('SETTINGS · Avatar uploaded successfully');
      }

      final locationValue = _locationCtrl.text.trim();
      final bioValue = _bioCtrl.text.trim();

      final result = await _updateAccountSettingsUseCase.execute(
        username: _usernameCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        location: locationValue.isNotEmpty ? locationValue : null,
        bio: bioValue.isNotEmpty ? bioValue : null,
        avatarUrl: uploadedAvatarUrl ?? (_avatarUrl.isNotEmpty ? _avatarUrl : null),
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() => _isSaving = false);
          LogHandler.error('Failed to update account settings: ${failure.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update settings: ${failure.message}'),
              backgroundColor: AppColors.cancel,
            ),
          );
        },
        (_) {
          setState(() {
            _firstName = _firstNameCtrl.text.trim();
            _lastName = _lastNameCtrl.text.trim();
            _username = _usernameCtrl.text.trim();
            _location = locationValue;
            _bio = bioValue;
            _avatarUrl = uploadedAvatarUrl ?? _avatarUrl;
            _selectedAvatarFile = null;
            _isEditing = false;
            _isSaving = false;
          });

          LogHandler.info(
            'Account settings updated from settings page: '
            'firstName=$_firstName, lastName=$_lastName, '
            'username=$_username, location=$_location, bio=$_bio, avatar=$_avatarUrl',
          );
          LogHandler.success('SETTINGS · SAVE ACCOUNT completed');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings updated successfully'),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      LogHandler.error('Failed to update account settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update settings: $e'),
          backgroundColor: AppColors.cancel,
        ),
      );
    }
  }

  Future<void> _pickAvatarImage() async {
    LogHandler.separator(title: 'SETTINGS · PICK AVATAR');
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked == null || !mounted) {
        LogHandler.warning('SETTINGS · Avatar pick canceled by user');
        return;
      }

      setState(() {
        _selectedAvatarFile = File(picked.path);
      });
      LogHandler.success('SETTINGS · Avatar selected: ${picked.name}');
    } catch (e) {
      if (!mounted) return;
      LogHandler.error('SETTINGS · Failed to pick avatar image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.cancel,
        ),
      );
    }
  }

  void _cancel() {
    _firstNameCtrl.text = _firstName;
    _lastNameCtrl.text = _lastName;
    _usernameCtrl.text = _username;
    _locationCtrl.text = _location;
    _bioCtrl.text = _bio;
    _emailCtrl.text = _email;
    setState(() {
      _selectedAvatarFile = null;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return PixelBorderContainer(
      pixelSize: 4,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Account Settings',
                style: AppTypography.titleSemiBold.copyWith(color: AppColors.title),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.close : Icons.edit,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() {
                  if (_isEditing) {
                    _cancel();
                  } else {
                    _isEditing = true;
                  }
                }),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Avatar + display name
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isEditing && !_isSaving ? _pickAvatarImage : null,
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBrand.withValues(alpha: 0.3),
                            border: Border.all(color: AppColors.secondaryBrand, width: 2.5),
                          ),
                          child: ClipOval(
                            child: _selectedAvatarFile != null
                                ? Image.file(_selectedAvatarFile!, fit: BoxFit.cover)
                                : (_avatarUrl.isNotEmpty
                                    ? Image.network(
                                        _avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(),
                                      )
                                    : _buildAvatarFallback()),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryBrand,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _username,
                  style: AppTypography.titleSemiBold.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Passion Gardener',
                  style: AppTypography.bodyRegular.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  'Member since May 2025',
                  style: AppTypography.smallBodyRegular.copyWith(color: AppColors.textDisabled),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 12),

          // Fields
          _buildField('First name', _firstName, _firstNameCtrl),
          _buildField('Last name', _lastName, _lastNameCtrl),
          _buildField('Username', _username, _usernameCtrl),
          _buildField('Email', _email, _emailCtrl, isReadOnly: true),
          _buildField('Location', _location, _locationCtrl),
          _buildField('Bio', _bio, _bioCtrl),
          _buildField('Password', '••••••••••', null, isPassword: true),

          // Cancel / Save (edit mode only)
          if (_isEditing) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    variant: AppButtonVariant.text,
                    text: 'Cancel',
                    backgroundColor: AppColors.surface,
                    onPressed: _cancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    variant: AppButtonVariant.text,
                    text: 'Save',
                    onPressed: _isSaving ? () {} : () => _save(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    String value,
    TextEditingController? controller, {
    bool isPassword = false,
    bool isReadOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.smallBodyRegular.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          if (_isEditing && !isPassword && controller != null)
            _buildInput(controller, readOnly: isReadOnly)
          else
            Text(
              isPassword ? '••••••••••' : value,
              style: AppTypography.bodyRegular.copyWith(
                color: isPassword ? AppColors.textDisabled : AppColors.iconbar,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, {bool readOnly = false}) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        border: Border.all(color: AppColors.primaryBrand),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: AppTypography.bodyRegular.copyWith(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Text(
        _username.isNotEmpty ? _username[0].toUpperCase() : '?',
        style: AppPixelTypography.h2.copyWith(color: AppColors.secondaryBrand),
      ),
    );
  }
}
