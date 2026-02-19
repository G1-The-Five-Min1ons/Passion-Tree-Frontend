import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/checkbox.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/homebar.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/widgets/bottom_buttons.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/widgets/pixel_password_field.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/register_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/register_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/register_state.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/widgets/select_role_popup.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/login_page.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc(
        authRepository: getIt<IAuthRepository>(),
      ),
      child: const _RegisterPageContent(),
    );
  }
}

class _RegisterPageContent extends StatefulWidget {
  const _RegisterPageContent();

  @override
  State<_RegisterPageContent> createState() => _RegisterPageContentState();
}

class _RegisterPageContentState extends State<_RegisterPageContent> {
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _firstNameError;
  String? _lastNameError;
  String? _termsError;

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


  String? _validateUsername(String value) {
    if (value.isEmpty) {
      return 'Username is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
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

  String? _validateName(String value, String fieldName) {
    if (value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  bool _validateAllFields() {
    setState(() {
      _usernameError = _validateUsername(_usernameController.text.trim());
      _firstNameError = _validateName(_firstNameController.text.trim(), 'First name');
      _lastNameError = _validateName(_lastNameController.text.trim(), 'Last name');
      _emailError = _validateEmail(_emailController.text.trim());
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text);
      _termsError = !_acceptTerms ? ' Please accept Terms and Privacy Policy' : null;
    });

    return _usernameError == null &&
        _firstNameError == null &&
        _lastNameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _termsError == null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) async {
        if (state is RegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.status,
            ),
          );

          // 1. Show role selection popup immediately after registration
          final selectedRole = await showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return SelectRolePopup(
                onRoleSelected: (role) {
                  Navigator.of(dialogContext).pop(role);
                },
              );
            },
          );

          if (selectedRole != null && state.userId.isNotEmpty) {
            final authRepo = getIt<IAuthRepository>();
            // Save role locally
            await authRepo.saveUserRole(selectedRole);
            await authRepo.markRoleSelected();
            
            // 2. Auto-login to trigger OTP
            if (context.mounted) {
               try {
                  // Show loading indicator or just block interaction? 
                  // For now, we rely on the OTP dialog to appear.
                  final logMsg = await authRepo.login(
                     identifier: _usernameController.text.trim(),
                     password: _passwordController.text,
                  );
                  
                  if (!context.mounted) return;
                  
                  // 3. Show OTP Dialog
                  final otpCode = await _showOtpDialog(context, logMsg);
                  
                  if (otpCode != null && context.mounted) {
                     // 4. Verify Email
                     await authRepo.verifyEmail(otpCode);
                     
                     // 5. Post-Auth Logic (Sync Role & Navigate)
                     await _handlePostAuth(context);
                  } else if (context.mounted) {
                      // User cancelled OTP, navigate to login page so they can try logging in again later
                       Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                           builder: (context) => const LoginPage(),
                        ),
                     );
                  }

               } catch (e) {
                  LogHandler.error('Auto-login/Verification failed during registration flow', error: e);
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Verification failed: ${e.toString()}')),
                     );
                     // Fallback to login page
                     Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                           builder: (context) => const LoginPage(),
                        ),
                     );
                  }
               }
            }
          } else {
             // User cancelled role selection or something went wrong, fallback to login
             if (!context.mounted) return;
             Navigator.of(context).pushReplacement(
               MaterialPageRoute(
                 builder: (context) => const LoginPage(),
               ),
             );
          }

        } else if (state is RegisterFailure) {
          final errorMessage = state.error.toLowerCase();
          
          bool isFieldError = false;
          
          if (errorMessage.contains('username')) {
            setState(() {
              _usernameError = 'Username is already taken';
            });
            isFieldError = true;
          } else if (errorMessage.contains('email')) {
            setState(() {
              _emailError = 'Email is already registered';
            });
            isFieldError = true;
          }
          
          // Show SnackBar for non-field errors
          if (!isFieldError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.cancel,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is RegisterLoading;
        
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelTextField(
                          label: 'Username *',
                          hintText: 'Enter a unique username',
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
                          )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelTextField(
                          label: 'First name *',
                          hintText: 'Enter your first name',
                          controller: _firstNameController,
                          height: 38,
                          onChanged: (value) {
                            setState(() {
                              _firstNameError = _validateName(value.trim(), 'First name');
                            });
                          },
                        ),
                        if (_firstNameError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4),
                            child: Text(
                              _firstNameError!,
                              style: AppTypography.bodyRegular.copyWith(
                                color: AppColors.cancel,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelTextField(
                          label: 'Last name *',
                          hintText: 'Enter your last name',
                          controller: _lastNameController,
                          height: 38,
                          onChanged: (value) {
                            setState(() {
                              _lastNameError = _validateName(value.trim(), 'Last name');
                            });
                          },
                        ),
                        if (_lastNameError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4),
                            child: Text(
                              _lastNameError!,
                              style: AppTypography.bodyRegular.copyWith(
                                color: AppColors.cancel,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelTextField(
                          label: 'Email *',
                          hintText: 'Enter your email',
                          controller: _emailController,
                          height: 38,
                          onChanged: (value) {
                            setState(() {
                              _emailError = _validateEmail(value.trim());
                            });
                          },
                        ),
                        if (_emailError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4),
                            child: Text(
                              _emailError!,
                              style: AppTypography.bodyRegular.copyWith(
                                color: AppColors.cancel,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelPasswordField(
                          label: 'Password *',
                          hintText: 'Enter Password',
                          controller: _passwordController,
                          height: 38,
                          onChanged: (value) {
                            setState(() {
                              _passwordError = _validatePassword(value);
                              if (_confirmPasswordController.text.isNotEmpty) {
                                _confirmPasswordError = _validateConfirmPassword(
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
                          )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelPasswordField(
                          label: 'Confirm password *',
                          hintText: 'Confirm your password',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          height: 38,
                          onChanged: (value) {
                            setState(() {
                              _confirmPasswordError = _validateConfirmPassword(value);
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
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            PixelCheckbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                  _termsError = !_acceptTerms ? 'You must accept Terms and Privacy Policy' : null;
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
                        if (_termsError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4),
                            child: Text(
                              _termsError!,
                              style: AppTypography.bodyRegular.copyWith(
                                color: AppColors.cancel,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      variant: AppButtonVariant.text,
                      text: isLoading ? 'Create account' : 'Create account',
                      onPressed: () {
                        if (!_validateAllFields()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fix the errors above'),
                              backgroundColor: AppColors.cancel,
                            ),
                          );
                          return;
                        }

                        // Trigger registration via Bloc
                        context.read<RegisterBloc>().add(
                          RegisterSubmitted(
                            username: _usernameController.text.trim(),
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            firstName: _firstNameController.text.trim(),
                            lastName: _lastNameController.text.trim(),
                          ),
                        );
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
    );},
    );
  }

  /// Show OTP input dialog and return the entered code
  Future<String?> _showOtpDialog(BuildContext context, String message) async {
    final otpController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 25),
          child: PixelBorderContainer(
            pixelSize: 4,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Email Verification',
                  style: AppPixelTypography.h3.copyWith(
                    color: Theme.of(dialogContext).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: AppTypography.bodySemiBold.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                PixelTextField(
                  label: 'Verification Code',
                  hintText: 'Enter 6-digit code',
                  controller: otpController,
                  height: 38,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        variant: AppButtonVariant.text,
                        text: 'Cancel',
                        backgroundColor: AppColors.cancel,
                        onPressed: () => Navigator.of(dialogContext).pop(null),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        variant: AppButtonVariant.text,
                        text: 'Verify',
                        onPressed: () {
                          final code = otpController.text.trim();
                          if (code.isNotEmpty) {
                            Navigator.of(dialogContext).pop(code);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Handle the post-authentication flow: save data, check role, navigate
  Future<void> _handlePostAuth(BuildContext context) async {
    final authRepo = getIt<IAuthRepository>();
    
    // 1. Capture local role
    final localRoleCandidate = await authRepo.getUserRole();
    LogHandler.info('Reg-PostAuth: Local role candidate is "$localRoleCandidate"');
    
    try {
      // 2. Fetch profile
      final profileDataMap = await authRepo.getProfile();
      
      String backendRole = 'pending';
      if (profileDataMap is Map<String, dynamic> && 
          profileDataMap['data'] != null && 
          profileDataMap['data']['user'] != null) {
         backendRole = profileDataMap['data']['user']['role'] ?? 'pending';
      }
      LogHandler.info('Reg-PostAuth: Backend role is "$backendRole"');

      // 3. Sync if needed
      if (backendRole == 'pending') {
         if (localRoleCandidate != null && (localRoleCandidate == 'student' || localRoleCandidate == 'teacher')) {
            try {
               LogHandler.info('Reg-PostAuth: Syncing role "$localRoleCandidate"...');
               await authRepo.selectRole(localRoleCandidate);
               LogHandler.success('Reg-PostAuth: Role synced.');
            } catch (e) {
               LogHandler.error('Reg-PostAuth: Failed to sync role', error: e);
            }
         } else {
             LogHandler.warning('Reg-PostAuth: No valid local role to sync. User remains pending.');
         }
      }
    } catch (e) {
      LogHandler.error('Reg-PostAuth: Profile fetch failed', error: e);
    }

    if (!context.mounted) return;

    LogHandler.success('Registration Flow Complete — navigating to home');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeBarWidget(),
      ),
    );
  }
}
