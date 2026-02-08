import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/checkbox.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/widgets/bottom_buttons.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/widgets/pixel_password_field.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_overview_login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                    // Title
                    const SizedBox(height: 8),
                    Text(
                      'Create an account',
                      style: AppPixelTypography.title.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reflect, learn and branch out your potential',
                      style: AppTypography.subtitleSemiBold.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    PixelTextField(
                      label: 'Username *',
                      hintText: 'Enter a unique username',
                      controller: _usernameController,
                      height: 38,
                    ),
                    const SizedBox(height: 16),
                    PixelTextField(
                      label: 'First name *',
                      hintText: 'Enter your first name',
                      controller: _firstNameController,
                      height: 38,
                    ),
                    const SizedBox(height: 16),
                    PixelTextField(
                      label: 'Last name *',
                      hintText: 'Enter your last name',
                      controller: _lastNameController,
                      height: 38,
                    ),
                    const SizedBox(height: 16),
                    PixelTextField(
                      label: 'Email *',
                      hintText: 'Enter your email',
                      controller: _emailController,
                      height: 38,
                    ),
                    const SizedBox(height: 16),
                    PixelPasswordField(
                      label: 'Password *',
                      hintText: 'Enter Password',
                      controller: _passwordController,
                      height: 38,
                    ),
                    const SizedBox(height: 16),
                    PixelPasswordField(
                          label: 'Confirm password *',
                          hintText: 'Confirm your password',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          height: 38,
                        ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        PixelCheckbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppTypography.subtitleMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                const TextSpan(text: 'I accept '),
                                TextSpan(
                                  text: 'Terms',
                                  style: AppTypography.subtitleMedium.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                  // TODO: Add gesture recognizer for Terms
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy.',
                                  style: AppTypography.subtitleMedium.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                  // TODO: Add gesture recognizer for Privacy Policy
                                ),
                                TextSpan(
                                  text: ' *',
                                  style: AppTypography.titleSemiBold.copyWith(
                                    color: colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      variant: AppButtonVariant.text,
                      text: 'Create account',
                      onPressed: () {
                        // TODO: Implement actual registration logic with backend
                        // For now, validate and navigate if basic checks pass
                        if (_usernameController.text.isNotEmpty &&
                            _firstNameController.text.isNotEmpty &&
                            _lastNameController.text.isNotEmpty &&
                            _emailController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty &&
                            _confirmPasswordController.text.isNotEmpty) {
                          
                          // Check if passwords match
                          if (_passwordController.text != _confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passwords do not match'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Check if terms are accepted
                          if (!_acceptTerms) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please accept Terms and Privacy Policy'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Navigate to logged-in page (registration successful)
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LearningPathOverviewLoginPage(),
                            ),
                          );
                        } else {
                          // Show error
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all required fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?  ',
                          style: AppTypography.titleRegular.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Sign in',
                            style: AppTypography.titleMedium.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
    
                    Text(
                      'Or continue with',
                      style: AppTypography.titleRegular.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                      

                    const SizedBox(height: 24),
                    BottomButtons(
                        onGoogleTap: () {
                          //TODO: Logic
                        },
                        onDiscordTap: () {
                          //TODO: Logic
                        },
                      )
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
