import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/resend_verification_email_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/verify_email_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/verify_email_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/verify_email_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/verify_email_usecase.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

class VerifyEmailPage extends StatelessWidget {
  final Function()? onSuccess;
  final VoidCallback? onCancel;
  final String verifyText;
  final String? resendEmail;
  final int resendCooldownSeconds;
  final int initialResendCooldownSeconds;

  const VerifyEmailPage({
    super.key,
    this.onSuccess,
    this.onCancel,
    this.verifyText = 'Verify',
    this.resendEmail,
    this.resendCooldownSeconds = 10,
    this.initialResendCooldownSeconds = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VerifyEmailBloc(
        verifyEmailUseCase: getIt<VerifyEmailUseCase>(),
        resendVerificationEmailUseCase:
            getIt<ResendVerificationEmailUseCase>(),
        initialResendEmail: resendEmail,
      ),
      child: BlocListener<VerifyEmailBloc, VerifyEmailState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.resendStatus != current.resendStatus ||
            previous.resendMessage != current.resendMessage,
        listener: (context, state) {
          if (state.status == VerifyEmailStatus.success) {
            Navigator.of(context).pop();
            if (onSuccess != null) {
              onSuccess!();
            }
          } else if (state.status == VerifyEmailStatus.cancelled) {
            Navigator.of(context).pop();
            if (onCancel != null) {
              onCancel!();
            }
          } else if (state.resendStatus == ResendVerificationStatus.success &&
              state.resendMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.resendMessage!),
                backgroundColor: AppColors.status,
              ),
            );
          } else if (state.resendStatus == ResendVerificationStatus.failure &&
              state.resendMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.resendMessage!),
                backgroundColor: AppColors.cancel,
              ),
            );
          }
        },
        child: _VerifyEmailDialog(
          verifyText: verifyText,
          initialResendEmail: resendEmail,
          resendCooldownSeconds: resendCooldownSeconds,
          initialResendCooldownSeconds: initialResendCooldownSeconds,
        ),
      ),
    );
  }
}

class _VerifyEmailDialog extends StatefulWidget {
  final String verifyText;
  final String? initialResendEmail;
  final int resendCooldownSeconds;
  final int initialResendCooldownSeconds;

  const _VerifyEmailDialog({
    required this.verifyText,
    this.initialResendEmail,
    required this.resendCooldownSeconds,
    required this.initialResendCooldownSeconds,
  });

  @override
  State<_VerifyEmailDialog> createState() => _VerifyEmailDialogState();
}

class _VerifyEmailDialogState extends State<_VerifyEmailDialog> {
  final _otpController = TextEditingController();
  late final TextEditingController _resendEmailController;
  Timer? _resendCooldownTimer;
  int _resendCooldownRemaining = 0;

  bool get _showResendEmailField =>
      widget.initialResendEmail == null || widget.initialResendEmail!.trim().isEmpty;

  bool get _isCooldownActive => _resendCooldownRemaining > 0;

  @override
  void initState() {
    super.initState();
    _resendEmailController = TextEditingController(
      text: widget.initialResendEmail?.trim() ?? '',
    );

    if (widget.initialResendCooldownSeconds > 0) {
      _startResendCooldown(widget.initialResendCooldownSeconds);
    }
  }

  @override
  void dispose() {
    _resendCooldownTimer?.cancel();
    _otpController.dispose();
    _resendEmailController.dispose();
    super.dispose();
  }

  void _startResendCooldown([int? seconds]) {
    final duration = seconds ?? widget.resendCooldownSeconds;

    _resendCooldownTimer?.cancel();

    if (duration <= 0) {
      if (mounted) {
        setState(() {
          _resendCooldownRemaining = 0;
        });
      }
      return;
    }

    setState(() {
      _resendCooldownRemaining = duration;
    });

    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendCooldownRemaining <= 1) {
        timer.cancel();
        setState(() {
          _resendCooldownRemaining = 0;
        });
        return;
      }

      setState(() {
        _resendCooldownRemaining--;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                child: BlocListener<VerifyEmailBloc, VerifyEmailState>(
                  listenWhen: (previous, current) =>
                      previous.resendStatus != current.resendStatus,
                  listener: (context, state) {
                    if (state.resendStatus == ResendVerificationStatus.success) {
                      _startResendCooldown();
                    }
                  },
                  child: BlocBuilder<VerifyEmailBloc, VerifyEmailState>(
                    builder: (context, state) {
                      final isVerifying = state.status == VerifyEmailStatus.loading;
                      final isResending =
                          state.resendStatus == ResendVerificationStatus.loading;
                      final canResend =
                          !isResending && !isVerifying && !_isCooldownActive;
                      final resendLabel = isResending
                          ? 'Resending...'
                          : _isCooldownActive
                          ? 'Resend OTP in ${_resendCooldownRemaining}s'
                          : 'Resend OTP';

                      return Column(
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
                          if (_showResendEmailField) ...[
                            const SizedBox(height: 20),
                            PixelTextField(
                              label: 'Email',
                              hintText: 'Enter your email to resend code',
                              controller: _resendEmailController,
                              height: 38,
                              onChanged: (value) {
                                context.read<VerifyEmailBloc>().add(
                                  ResendEmailChanged(value),
                                );
                              },
                            ),
                            if (state.resendEmailError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  state.resendEmailError!,
                                  style: AppTypography.bodyRegular.copyWith(
                                    color: AppColors.cancel,
                                  ),
                                ),
                              ),
                          ],
                          const SizedBox(height: 24),
                          PixelTextField(
                            label: 'Verification Code',
                            hintText: 'Enter 6-digit code',
                            controller: _otpController,
                            height: 38,
                            onChanged: (value) {
                              context.read<VerifyEmailBloc>().add(
                                OtpCodeChanged(value),
                              );
                            },
                          ),
                          if (state.otpError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                state.otpError!,
                                style: AppTypography.bodyRegular.copyWith(
                                  color: AppColors.cancel,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: canResend
                                  ? () {
                                      if (_showResendEmailField) {
                                        context.read<VerifyEmailBloc>().add(
                                          ResendEmailChanged(
                                            _resendEmailController.text,
                                          ),
                                        );
                                      }
                                      context.read<VerifyEmailBloc>().add(
                                        const ResendVerificationEmailRequested(),
                                      );
                                    }
                                  : null,
                              child: Text(
                                resendLabel,
                                style: AppTypography.bodySemiBold.copyWith(
                                  color: canResend
                                      ? Theme.of(context).colorScheme.primary
                                      : AppColors.textDisabled,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SaveCancel(
                            saveText: isVerifying ? 'Verifying...' : widget.verifyText,
                            saveButtonColor: AppColors.submit,
                            cancelText: 'Cancel',
                            onCancel: () {
                              context.read<VerifyEmailBloc>().add(
                                const CancelVerifyEmail(),
                              );
                            },
                            onSave: isVerifying || isResending
                                ? null
                                : () {
                                    context.read<VerifyEmailBloc>().add(
                                      const SubmitVerifyEmail(),
                                    );
                                  },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
