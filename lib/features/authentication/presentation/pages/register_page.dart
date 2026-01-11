import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/checkbox.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(
                  color: colorScheme.onSurface,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'Create an account',
                    style: AppPixelTypography.h2.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reflect, learn and branch out your potential',
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PixelTextField(
                    label: 'Username *',
                    hintText: 'Enter a unique username',
                    controller: _usernameController,
                    height: 46,
                  ),
                  const SizedBox(height: 16),
                  PixelTextField(
                    label: 'First name *',
                    hintText: 'Enter your first name',
                    controller: _firstNameController,
                    height: 46,
                  ),
                  const SizedBox(height: 16),
                  PixelTextField(
                    label: 'Last name *',
                    hintText: 'Enter your last name',
                    controller: _lastNameController,
                    height: 46,
                  ),
                  const SizedBox(height: 16),
                  PixelTextField(
                    label: 'Email *',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    height: 46,
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      PixelPasswordField(
                        label: 'Password *',
                        hintText: 'Enter your password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        height: 46,
                      ),
                      Positioned(
                        right: 12,
                        bottom: 13,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      PixelPasswordField(
                        label: 'confirm password *',
                        hintText: 'Confirm your password',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        height: 46,
                      ),
                      Positioned(
                        right: 12,
                        bottom: 13,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                          child: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
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
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.bodyRegular.copyWith(
                              color: colorScheme.onSurface,
                            ),
                            children: [
                              const TextSpan(text: 'I accept '),
                              TextSpan(
                                text: 'Terms',
                                style: AppTypography.bodyRegular.copyWith(
                                  color: colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                                // TODO: Add gesture recognizer for Terms
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy.',
                                style: AppTypography.bodyRegular.copyWith(
                                  color: colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                                // TODO: Add gesture recognizer for Privacy Policy
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
                        style: AppTypography.bodyRegular.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Sign in',
                          style: AppTypography.bodyRegular.copyWith(
                            color: colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
                          style: AppTypography.bodyRegular.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          variant: AppButtonVariant.textWithIcon,
                          text: 'Google',
                          icon: Image.asset(
                            'assets/icons/google.png',
                            width: 16,
                            height: 16,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.g_mobiledata, size: 16);
                            },
                          ),
                          onPressed: () {
                            // TODO: Implement Google OAuth
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          variant: AppButtonVariant.textWithIcon,
                          text: 'Discord',
                          icon: Image.asset(
                            'assets/icons/discord.png',
                            width: 16,
                            height: 16,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.discord, size: 16);
                            },
                          ),
                          onPressed: () {
                            // TODO: Implement Discord OAuth
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
    );
  }
}
