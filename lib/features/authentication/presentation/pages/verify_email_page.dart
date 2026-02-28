import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/verify_email_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/verify_email_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/verify_email_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/verify_email_usecase.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

class VerifyEmailPage extends StatelessWidget {
  final Function()? onSuccess;
  final VoidCallback? onCancel;
  final String verifyText;

  const VerifyEmailPage({
    super.key,
    this.onSuccess,
    this.onCancel,
    this.verifyText = 'Verify',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VerifyEmailBloc(
        verifyEmailUseCase: getIt<VerifyEmailUseCase>(),
      ),
      child: BlocListener<VerifyEmailBloc, VerifyEmailState>(
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
          } else if (state.status == VerifyEmailStatus.failure) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.cancel,
                ),
              );
            }
          }
        },
        child: _VerifyEmailDialog(verifyText: verifyText),
      ),
    );
  }
}

class _VerifyEmailDialog extends StatefulWidget {
  final String verifyText;

  const _VerifyEmailDialog({required this.verifyText});

  @override
  State<_VerifyEmailDialog> createState() => _VerifyEmailDialogState();
}

class _VerifyEmailDialogState extends State<_VerifyEmailDialog> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
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
                child: BlocBuilder<VerifyEmailBloc, VerifyEmailState>(
                  builder: (context, state) {
                    //final isLoading = state.status == VerifyEmailStatus.loading;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Email Verification test',
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
                          onChanged: (value) {
                            context.read<VerifyEmailBloc>().add(OtpCodeChanged(value));
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
                        const SizedBox(height: 24),
                        SaveCancel(
                          saveText: widget.verifyText,
                          saveButtonColor: AppColors.submit,
                          cancelText: 'Cancel',
                          onCancel: () { 
                            context.read<VerifyEmailBloc>().add(const CancelVerifyEmail());
                          },
                          onSave: () {
                            context.read<VerifyEmailBloc>().add(const SubmitVerifyEmail());
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
    );
  }
}
