import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';

class VerifyEmailPage extends StatefulWidget {
  final Function(String) onVerify;
  final VoidCallback onCancel;
  final bool isLoading;
  final String? error;

  const VerifyEmailPage({
    super.key,
    required this.onVerify,
    required this.onCancel,
    this.isLoading = false,
    this.error,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If error is present, show snackbar (handled by parent usually, but can show here too)
    // We'll rely on parent listener or display error text below input.

    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: PixelBorderContainer(
                pixelSize: 4,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Email Verification',
                      style: AppPixelTypography.h3.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please enter the 6-digit code sent to your email.',
                      style: AppTypography.bodySemiBold.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    PixelTextField(
                      label: 'Verification Code',
                      hintText: 'Enter 6-digit code',
                      controller: _otpController,
                      height: 38,
                    ),
                    if (widget.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          widget.error!,
                          style: AppTypography.bodyRegular.copyWith(
                            color: AppColors.cancel,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            variant: AppButtonVariant.text,
                            text: 'Cancel',
                            backgroundColor: AppColors.cancel,
                            onPressed: widget.isLoading ? () {} : widget.onCancel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            variant: AppButtonVariant.text,
                            text: widget.isLoading ? 'Verifying...' : 'Verify',
                            onPressed: widget.isLoading
                                ? () {}
                                : () {
                                    final code = _otpController.text.trim();
                                    if (code.isNotEmpty) {
                                      widget.onVerify(code);
                                    }
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
        ),
      ),
    );
  }
}
