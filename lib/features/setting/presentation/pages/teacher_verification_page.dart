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
        const SnackBar(content: Text('Please fill all required fields.', style: TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.cancel),
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
        const SnackBar(content: Text('Application submitted successfully.', style: TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.status),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit application: $e', style: const TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.cancel),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarWidget(
        title: 'Teacher Verification',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

                  // ── Status banner ──────────────────────────────────
                  _buildStatusBanner(),
                  const SizedBox(height: 16),

                  // ── Body depending on status ───────────────────────
                  if (_status != null &&
                      _status!.applicationStatus == 'pending')
                    _buildPendingView()
                  else if (_status != null &&
                      (_status!.applicationStatus == 'approved' ||
                          _status!.isVerified))
                    _buildApprovedView()
                  else ...[
                    // none / rejected → show form
                    if (_status != null &&
                        _status!.applicationStatus == 'rejected')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Your previous application was rejected. You may re-apply below.',
                          style: AppTypography.bodyRegular.copyWith(
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ),
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
                      hint:
                          'Share your teaching background and experience.',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      variant: AppButtonVariant.text,
                      text: _isSubmitting
                          ? 'Submitting...'
                          : 'Apply for Teacher',
                      onPressed: _isSubmitting ? () {} : _submit,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  // ── Status banner ────────────────────────────────────────────────────

  Widget _buildStatusBanner() {
    final status = _status;
    if (status == null) return const SizedBox.shrink();

    final String label;
    final Color color;
    final IconData icon;

    if (status.isVerified || status.applicationStatus == 'approved') {
      label = 'Status: Verified';
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (status.applicationStatus == 'pending') {
      label = 'Status: Pending Review';
      color = Colors.amber;
      icon = Icons.hourglass_top;
    } else if (status.applicationStatus == 'rejected') {
      label = 'Status: Rejected';
      color = Colors.redAccent;
      icon = Icons.cancel;
    } else {
      label = 'Status: Not Applied';
      color = AppColors.textPrimary;
      icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: color.withValues(alpha:0.6)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySemiBold.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pending view ─────────────────────────────────────────────────────

  Widget _buildPendingView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha:0.08),
            border: Border.all(color: Colors.amber.withValues(alpha:0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.hourglass_top,
                  color: Colors.amber, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your application has been submitted and is waiting for admin approval.',
                  style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_status!.phoneNumber.isNotEmpty) ...[
          _buildReadOnlyField(
              label: 'Phone Number', value: _status!.phoneNumber),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  // ── Approved / Verified view ─────────────────────────────────────────

  Widget _buildApprovedView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha:0.08),
        border: Border.all(color: Colors.green.withValues(alpha:0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your teacher account has been verified! You can now create learning paths.',
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Read-only field ──────────────────────────────────────────────────

  Widget _buildReadOnlyField({
    required String label,
    required String value,
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha:0.5),
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Editable field ───────────────────────────────────────────────────

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
