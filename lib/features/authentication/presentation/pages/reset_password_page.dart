import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/widgets/pixel_password_field.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/reset_password_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/reset_password_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/reset_password_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/reset_password_usecase.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResetPasswordBloc(
        resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ResetPasswordBloc, ResetPasswordState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == ResetPasswordStatus.success) {
                LogHandler.success('Password reset successfully');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset successfully! Please sign in.'),
                    backgroundColor: AppColors.status,
                  ),
                );
                // Pop back to login page (pop twice)
                Navigator.of(context)
                  ..pop()
                  ..pop();
              } else if (state.status == ResetPasswordStatus.failure) {
                LogHandler.error('Reset password failed', error: state.errorMessage);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'An error occurred'),
                    backgroundColor: AppColors.cancel,
                  ),
                );
              }
            },
          ),
        ],
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: PixelBorderContainer(
                pixelSize: 4,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/icons/tree_icon.png',
                        width: 80,
                        height: 80,
                        cacheWidth: 240,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: AppColors.status,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Reset Password',
                      style: AppPixelTypography.h2.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'We sent a reset code to ${widget.email}. Enter it below with your new password.',
                      style: AppTypography.bodySemiBold.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Code field
                    BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PixelTextField(
                              label: 'Reset Code',
                              hintText: 'Enter the code from your email',
                              controller: _codeController,
                              height: 38,
                              onChanged: (value) {
                                context.read<ResetPasswordBloc>().add(CodeChanged(value));
                              },
                            ),
                            if (state.codeError != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 12, top: 4),
                                child: Text(
                                  state.codeError!,
                                  style: AppTypography.bodyRegular.copyWith(
                                    color: AppColors.cancel,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // New password field
                    BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PixelPasswordField(
                              label: 'New Password',
                              hintText: 'Enter new password',
                              controller: _passwordController,
                              height: 38,
                              onChanged: (value) {
                                context.read<ResetPasswordBloc>().add(PasswordChanged(value));
                              },
                            ),
                            if (state.passwordError != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 12, top: 4),
                                child: Text(
                                  state.passwordError!,
                                  style: AppTypography.bodyRegular.copyWith(
                                    color: AppColors.cancel,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Confirm password field
                    BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PixelPasswordField(
                              label: 'Confirm Password',
                              hintText: 'Confirm new password',
                              controller: _confirmPasswordController,
                              height: 38,
                              onChanged: (value) {
                                context.read<ResetPasswordBloc>().add(ConfirmPasswordChanged(value));
                              },
                            ),
                            if (state.confirmPasswordError != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 12, top: 4),
                                child: Text(
                                  state.confirmPasswordError!,
                                  style: AppTypography.bodyRegular.copyWith(
                                    color: AppColors.cancel,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Reset button
                    BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
                      builder: (context, state) {
                        final isLoading = state.status == ResetPasswordStatus.loading;
                        return AppButton(
                          variant: AppButtonVariant.text,
                          text: isLoading ? 'Resetting...' : 'Reset Password',
                          onPressed: isLoading
                              ? () {}
                              : () {
                                  context.read<ResetPasswordBloc>().add(const SubmitResetPassword());
                                },
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Back to login
                    GestureDetector(
                      onTap: () {
                        // Pop back to login (pop twice)
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      },
                      child: Text(
                        'Back to Sign In',
                        style: AppTypography.titleMedium.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
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
