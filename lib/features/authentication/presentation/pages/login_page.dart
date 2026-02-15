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
import 'package:passion_tree_frontend/features/authentication/data/services/auth_api_service.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/auth_models.dart';
import 'package:passion_tree_frontend/features/authentication/data/services/token_storage_service.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_overview_login_page.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  
  String? _usernameError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // Validation methods
  String? _validateUsername(String value) {
    if (value.isEmpty) {
      return 'Username or email is required';
    }
    return null;
  }
  
  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }
  
  bool _validateAllFields() {
    setState(() {
      _usernameError = _validateUsername(_usernameController.text.trim());
      _passwordError = _validatePassword(_passwordController.text);
    });
    
    return _usernameError == null && _passwordError == null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
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
                    // Logo/Icon
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
                      'Sign In',
                      style: AppPixelTypography.h2.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      'Ready to continue growing your reflection tree?',
                      style: AppTypography.bodySemiBold.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Username field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelTextField(
                          label: 'Username or Email',
                          hintText: 'Enter your username or email',
                          controller: _usernameController,
                          height: 38,
                          onChanged: (value) {
                            setState(() {
                              _usernameError = _validateUsername(value.trim());
                            });
                          },
                        ),
                        if (_usernameError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4),
                            child: Text(
                              _usernameError!,
                              style: AppTypography.bodyRegular.copyWith(
                                color: AppColors.cancel,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Password field with visibility toggle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelPasswordField(
                          label: 'Password',
                          hintText: 'Enter Password',
                          controller: _passwordController,
                          height: 38,
                          onChanged: (value) {
                            setState(() {
                              _passwordError = _validatePassword(value);
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
                    const SizedBox(height: 16),

                    // Remember me & Forgot password
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        PixelCheckbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remember me',
                          style: AppTypography.subtitleMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            // TODO: Navigate to forgot password page
                          },
                          child: Text(
                            'Forgot password',
                            style: AppTypography.subtitleMedium.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sign in button
                    AppButton(
                      variant: AppButtonVariant.text,
                      text: _isLoading ? 'Sign in' : 'Sign in',
                      onPressed: () async {
                        // Validate fields
                        if (!_validateAllFields()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fix the errors above'),
                              backgroundColor: AppColors.cancel,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          final authService = AuthApiService();
                          final request = LoginRequest(
                            identifier: _usernameController.text.trim(),
                            password: _passwordController.text,
                          );

                          final response = await authService.login(request);

                          // Save token if remember me is checked
                          if (_rememberMe && response.token != null) {
                            await TokenStorageService().saveToken(response.token);
                          }

                          if (!mounted) return;

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Login successful!'),
                              backgroundColor: AppColors.status,
                            ),
                          );

                          // Navigate to main page
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LearningPathOverviewLoginPage(),
                            ),
                          );
                        } on AuthException catch (e) {
                          if (!mounted) return;

                          setState(() {
                            _isLoading = false;
                          });

                          // Show error in snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.message),
                              backgroundColor: AppColors.cancel,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;

                          setState(() {
                            _isLoading = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('An error occurred: ${e.toString()}'),
                              backgroundColor: AppColors.cancel,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?  ",
                          style: AppTypography.titleRegular.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign up',
                            style: AppTypography.titleMedium.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Divider with text
                    Text(
                      'Or continue with',
                      style: AppTypography.titleRegular.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // OAuth buttons
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
    );
  }
}
