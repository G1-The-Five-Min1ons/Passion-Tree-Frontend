import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/widgets/pixel_password_field.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';

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

  String? _codeError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateCode(String value) {
    if (value.isEmpty) {
      return 'Reset code is required';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String value) {
    if (value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool _validateAllFields() {
    setState(() {
      _codeError = _validateCode(_codeController.text.trim());
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError =
          _validateConfirmPassword(_confirmPasswordController.text);
    });
    return _codeError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  Future<void> _handleResetPassword() async {
    if (!_validateAllFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors above'),
          backgroundColor: AppColors.cancel,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = getIt<IAuthRepository>();
      await authRepo.resetPassword(
        _codeController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      LogHandler.success('Password reset successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully! Please sign in.'),
          backgroundColor: AppColors.status,
        ),
      );

      // Pop back to login page (pop twice: ResetPassword → ForgotPassword → Login)
      Navigator.of(context)
        ..pop()
        ..pop();
    } catch (e) {
      if (!mounted) return;
      LogHandler.error('Reset password failed', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.cancel,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelTextField(
                          label: 'Reset Code',
                          hintText: 'Enter the code from your email',
                          controller: _codeController,
                          height: 38,
                          onChanged: (value) {
                            setState(() {
                              _codeError = _validateCode(value.trim());
                            });
                          },
                        ),
                        if (_codeError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4),
                            child: Text(
                              _codeError!,
                              style: AppTypography.bodyRegular.copyWith(
                                color: AppColors.cancel,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // New password field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelPasswordField(
                          label: 'New Password',
                          hintText: 'Enter new password',
                          controller: _passwordController,
                          height: 38,
                          onChanged: (value) {
                            setState(() {
                              _passwordError = _validatePassword(value);
                              if (_confirmPasswordController.text.isNotEmpty) {
                                _confirmPasswordError =
                                    _validateConfirmPassword(
                                  _confirmPasswordController.text,
                                );
                              }
                            });
                          },
                        ),
                        if (_passwordError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4),
                            child: Text(
                              _passwordError!,
                              style: AppTypography.bodyRegular.copyWith(
                                color: AppColors.cancel,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Confirm password field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelPasswordField(
                          label: 'Confirm Password',
                          hintText: 'Confirm new password',
                          controller: _confirmPasswordController,
                          height: 38,
                          onChanged: (value) {
                            setState(() {
                              _confirmPasswordError =
                                  _validateConfirmPassword(value);
                            });
                          },
                        ),
                        if (_confirmPasswordError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4),
                            child: Text(
                              _confirmPasswordError!,
                              style: AppTypography.bodyRegular.copyWith(
                                color: AppColors.cancel,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Reset button
                    AppButton(
                      variant: AppButtonVariant.text,
                      text: _isLoading ? 'Resetting...' : 'Reset Password',
                      onPressed: _isLoading ? () {} : _handleResetPassword,
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
