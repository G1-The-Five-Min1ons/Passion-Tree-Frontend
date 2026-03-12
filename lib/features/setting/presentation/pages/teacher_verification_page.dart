import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/teacher_verification_status.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class TeacherVerificationPage extends StatefulWidget {
  const TeacherVerificationPage({super.key});

  @override
  State<TeacherVerificationPage> createState() =>
      _TeacherVerificationPageState();
}

class _TeacherVerificationPageState extends State<TeacherVerificationPage> {
  final IAuthRepository _authRepository = getIt<IAuthRepository>();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _historyController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  TeacherVerificationStatus? _status;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _reasonController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    try {
      final status = await _authRepository.getTeacherVerificationStatus();
      if (!mounted) return;
      setState(() {
        _status = status;
        _phoneController.text = status.phoneNumber;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final reason = _reasonController.text.trim();
    final history = _historyController.text.trim();

    if (phone.isEmpty || reason.isEmpty || history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _authRepository.applyForTeacher(
        phoneNumber: phone,
        reason: reason,
        teachingHistory: history,
      );

      if (!mounted) return;
      await _loadStatus();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit application: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarWidget(
        title: 'Teacher Verification',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Verify your teacher account before creating a learning path.',
                    style: AppTypography.subtitleSemiBold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (status != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.isVerified
                            ? 'Status: Verified'
                            : 'Status: ${status.applicationStatus}',
                        style: AppTypography.bodySemiBold.copyWith(
                          color: status.isVerified
                              ? Colors.green
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    hint: 'e.g. 0812345678',
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    label: 'Reason for applying',
                    controller: _reasonController,
                    hint: 'Why do you want to become a teacher?',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    label: 'Teaching history',
                    controller: _historyController,
                    hint: 'Share your teaching background and experience.',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    variant: AppButtonVariant.text,
                    text: _isSubmitting ? 'Submitting...' : 'Apply for Teacher',
                    onPressed: _isSubmitting ? () {} : _submit,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.subtitleSemiBold.copyWith(
            color: AppColors.title,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTypography.bodyRegular.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyRegular.copyWith(
              color: AppColors.textSecondary,
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
      ],
    );
  }
}
