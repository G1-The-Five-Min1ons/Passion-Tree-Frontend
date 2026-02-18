import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/checkbox.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/widgets/bottom_buttons.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/widgets/pixel_password_field.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/widgets/select_role_popup.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/error/exceptions.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/auth_models.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/homebar.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/register_page.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

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

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initGoogleSignIn();
    _initDeepLinks();
  }

  Future<void> _initGoogleSignIn() async {
    // GoogleSignIn v7 requires initialization
    await GoogleSignIn.instance.initialize();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Check initial link if app was started by a deep link
    _checkInitialLink();

    // Listen to link changes
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  Future<void> _checkInitialLink() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      // Ignore errors
    }
  }

  void _handleDeepLink(Uri uri) {
    // Check if it's the specific Discord auth callback
    // scheme: passiontree, host: auth, path: /callback
    if (uri.scheme == 'passiontree' && 
        uri.host == 'auth' && 
        uri.path == '/callback') {
      
      final code = uri.queryParameters['code'];
      if (code != null) {
        _handleDiscordCode(code);
      }
    }
  }

  Future<void> _handleDiscordCode(String code) async {
    setState(() => _isLoading = true);
    try {
      final authRepo = getIt<IAuthRepository>();
      await authRepo.nativeDiscordSignIn(code);
      await _handlePostAuth();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      LogHandler.error('Discord login failed', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Discord login failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      // Google SignIn v7 migration: use instance and authenticate()
      // Scopes should be requested via authorizationClient if needed, 
      // but default sign-in often provides basic profile/email.
      // If we need specific scopes, we might need:
      // await GoogleSignIn.instance.requestScopes(['email', 'profile']); 
      // But standard login usually implies email/profile.
      
      final account = await GoogleSignIn.instance.authenticate();
      if (account == null) {
        setState(() => _isLoading = false);
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken != null) {
        final authRepo = getIt<IAuthRepository>();
        await authRepo.nativeGoogleSignIn(idToken);
        await _handlePostAuth();
      } else {
        throw Exception('Failed to retrieve Google ID Token');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      LogHandler.error('Google login failed', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleDiscordLogin() async {
    // TODO: Replace with actual Client ID
    const clientId = 'YOUR_DISCORD_CLIENT_ID'; 
    const redirectUri = 'passiontree://auth/callback';
    const scope = 'identify email connections guild.join';
    
    final url = Uri.parse(
      'https://discord.com/api/oauth2/authorize?client_id=$clientId&redirect_uri=$redirectUri&response_type=code&scope=$scope',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        // Do not set loading to false here, wait for callback
        // or set it to true to show spinner while browser opens
        setState(() => _isLoading = true);
      } else {
        throw Exception('Could not launch Discord login');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch Discord login: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
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

  /// Show OTP input dialog and return the entered code
  Future<String?> _showOtpDialog(String message) async {
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

  /// Show role selection popup and return the selected role
  Future<String?> _showRoleSelection() async {
    return showDialog<String>(
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
  }

  /// Handle the post-authentication flow: save data, check role, navigate
  Future<void> _handlePostAuth() async {
    final authRepo = getIt<IAuthRepository>();
    // Tokens are already saved by verifyEmail or nativeGoogleSignIn in the repository

    // Fetch user profile (Repository logic should cache user data)
    try {
      final profileData = await authRepo.getProfile();
      // If repository handles caching, we just need to verify success.
      // profileData is dynamic/map, waiting for typed entity in future refactor.
      
      // Check if role has been selected
      final roleSelected = await authRepo.hasSelectedRole();
      if (!roleSelected) {
        if (!mounted) return;
        final selectedRole = await _showRoleSelection();
        if (selectedRole != null) {
          await authRepo.saveUserRole(selectedRole);
          await authRepo.markRoleSelected();
          LogHandler.success('Role selected: $selectedRole');
        }
      }
    } catch (profileError) {
      LogHandler.error('Failed to fetch profile', error: profileError);
      // Still allow navigation even if profile fetch fails
    }

    if (!mounted) return;

    LogHandler.success('Login successful — navigating to home');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeBarWidget(),
      ),
    );
  }

  /// Full login flow: login → OTP → verify → role selection → navigate
  Future<void> _handleLogin() async {
    if (!_validateAllFields()) {
      LogHandler.warning('Login validation failed');
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

      // Step 1: Login → triggers OTP email
      final message = await authRepo.login(
        identifier: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Step 2: Show OTP dialog
      final otpCode = await _showOtpDialog(message);
      if (otpCode == null) {
        // User cancelled
        setState(() => _isLoading = false);
        return;
      }

      // Step 3: Verify email with OTP → get tokens (saved by repo)
      await authRepo.verifyEmail(otpCode);

      // Step 4+5+6: Post-auth flow (save, role check, navigate)
      await _handlePostAuth();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      LogHandler.error('Auth error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.cancel,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      LogHandler.error('Unexpected error', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: AppColors.cancel,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Dialog(
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordPage(),
                              ),
                            );
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
                      text: _isLoading ? 'Signing in...' : 'Sign in',
                      onPressed: _isLoading ? () {} : _handleLogin,
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
                      onGoogleTap: _handleGoogleLogin,
                      onDiscordTap: _handleDiscordLogin,
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
