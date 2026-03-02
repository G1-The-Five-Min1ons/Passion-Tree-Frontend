import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/reset_password_page.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/forgot_password_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/forgot_password_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/forgot_password_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/forgot_password_usecase.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordBloc(
        forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == ForgotPasswordStatus.success) {
                LogHandler.success('Password reset email sent');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ResetPasswordPage(email: state.email),
                  ),
                );
              } else if (state.status == ForgotPasswordStatus.failure) {
                LogHandler.error('Forgot password failed', error: state.errorMessage);
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
                      'Forgot Password',
                      style: AppPixelTypography.h2.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Enter your email address and we\'ll send you a code to reset your password.',
                      style: AppTypography.bodySemiBold.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Email field
                    BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PixelTextField(
                              label: 'Email',
                              hintText: 'Enter your email',
                              controller: _emailController,
                              height: 38,
                              onChanged: (value) {
                                context.read<ForgotPasswordBloc>().add(EmailChanged(value));
                              },
                            ),
                            if (state.emailError != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 12, top: 4),
                                child: Text(
                                  state.emailError!,
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

                    // Submit button
                    BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                      builder: (context, state) {
                        final isLoading = state.status == ForgotPasswordStatus.loading;
                        return AppButton(
                          variant: AppButtonVariant.text,
                          text: isLoading ? 'Sending...' : 'Send Reset Code',
                          onPressed: isLoading
                              ? () {}
                              : () {
                                  context.read<ForgotPasswordBloc>().add(const SubmitForgotPassword());
                                },
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Back to login
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
