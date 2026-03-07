import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';

class AccountSettingsSection extends StatefulWidget {
  const AccountSettingsSection({super.key});

  @override
  State<AccountSettingsSection> createState() => _AccountSettingsSectionState();
}

class _AccountSettingsSectionState extends State<AccountSettingsSection> {
  // Profile data
  String _firstName = 'Nathan';
  String _lastName = 'Sanchez';
  String _username = 'Xenoszz';
  String _phone = '099-5169210';
  String _gender = 'Male';
  String _dob = '01/06/2004';
  String _location = 'Bangkok,Thailand';
  String _email = 'Nathan.xen@gmail.com';
  bool _isEditing = false;

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: _firstName);
    _lastNameCtrl = TextEditingController(text: _lastName);
    _usernameCtrl = TextEditingController(text: _username);
    _phoneCtrl = TextEditingController(text: _phone);
    _genderCtrl = TextEditingController(text: _gender);
    _dobCtrl = TextEditingController(text: _dob);
    _locationCtrl = TextEditingController(text: _location);
    _emailCtrl = TextEditingController(text: _email);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _genderCtrl.dispose();
    _dobCtrl.dispose();
    _locationCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      _firstName = _firstNameCtrl.text;
      _lastName = _lastNameCtrl.text;
      _username = _usernameCtrl.text;
      _phone = _phoneCtrl.text;
      _gender = _genderCtrl.text;
      _dob = _dobCtrl.text;
      _location = _locationCtrl.text;
      _email = _emailCtrl.text;
      _isEditing = false;
    });
  }

  void _cancel() {
    _firstNameCtrl.text = _firstName;
    _lastNameCtrl.text = _lastName;
    _usernameCtrl.text = _username;
    _phoneCtrl.text = _phone;
    _genderCtrl.text = _gender;
    _dobCtrl.text = _dob;
    _locationCtrl.text = _location;
    _emailCtrl.text = _email;
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
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
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBrand.withValues(alpha: 0.3),
                    border: Border.all(color: AppColors.secondaryBrand, width: 2.5),
                  ),
                  child: Center(
                    child: Text(
                      _username.isNotEmpty ? _username[0].toUpperCase() : '?',
                      style: AppPixelTypography.h2.copyWith(color: AppColors.secondaryBrand),
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
          _buildField('Phone number', _phone, _phoneCtrl),
          _buildField('Gender', _gender, _genderCtrl),
          _buildField('Date of birth', _dob, _dobCtrl),
          _buildField('Location', _location, _locationCtrl),
          _buildField('Email', _email, _emailCtrl),
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
                    onPressed: _save,
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
            _buildInput(controller)
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

  Widget _buildInput(TextEditingController controller) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        border: Border.all(color: AppColors.primaryBrand),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        style: AppTypography.bodyRegular.copyWith(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
