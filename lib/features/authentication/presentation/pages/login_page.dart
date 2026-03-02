import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:passion_tree_frontend/core/common_widgets/bars/homebar.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/register_page.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_state.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/user_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/user_event.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
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
  
  String? _usernameError;
  String? _passwordError;

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
        // Dispatch Discord code authentication event
        context.read<LoginBloc>().add(LoginWithDiscordCode(code));
      }
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

    // Dispatch event to initiate Discord OAuth
    context.read<LoginBloc>().add(const LoginWithDiscord());
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch Discord login');
      }
    } catch (e) {
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

  /// Handle login button press
  void _handleLogin(BuildContext context) {
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

    final bloc = context.read<LoginBloc>();
    bloc.add(LoginUsernameChanged(_usernameController.text.trim()));
    bloc.add(LoginPasswordChanged(_passwordController.text));
    bloc.add(const LoginSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) => LoginBloc(
        loginWithCredentials: getIt(),
        loginWithGoogle: getIt(),
        loginWithDiscord: getIt(),
        verifyEmail: getIt(),
        getProfile: getIt(),
        selectRole: getIt(),
        getUserRole: getIt(),
      ),
      child: MultiBlocListener(
        listeners: [
          // Error listener
          BlocListener<LoginBloc, LoginState>(
            listenWhen: (previous, current) => current.status == LoginStatus.failure,
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: AppColors.cancel,
                  ),
                );
              }
            },
          ),
          // Navigation listener
          BlocListener<LoginBloc, LoginState>(
            listenWhen: (previous, current) =>
                current.status == LoginStatus.success && current.nextStep != null,
            listener: (context, state) async {
              switch (state.nextStep!) {
                case LoginNextStep.otpVerification:
                  await _showOtpDialog(context);
                  break;

                case LoginNextStep.checkingRole:
                  if (context.mounted) {
                    context.read<LoginBloc>().add(const CheckRoleStatus());
                  }
                  break;

                case LoginNextStep.roleSelection:
                  await _showRoleSelectionDialog(context);
                  break;

                case LoginNextStep.complete:
                  if (context.mounted) {
                    // Load user data into UserBloc before navigation
                    try {
                      final userId = await getIt<IAuthRepository>().getUserId();
                      if (userId != null && context.mounted) {
                        context.read<UserBloc>().add(LoadUser(userId));
                      }
                    } catch (e) {
                      // Log error but continue navigation
                      debugPrint('Failed to load user data: $e');
                    }
                    
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const HomeBarWidget(),
                        ),
                      );
                    }
                  }
                  break;
              }
            },
          ),
        ],
        child: _buildLoginForm(context, colorScheme),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, ColorScheme colorScheme) {
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
                child: BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    final isLoading = state.status == LoginStatus.loading;

                    return Column(
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
                              value: state.rememberMe,
                              onChanged: (value) {
                                context.read<LoginBloc>().add(
                                      LoginRememberMeToggled(value ?? false),
                                    );
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
                          text: isLoading ? 'Signing in...' : 'Sign in',
                          onPressed: isLoading ? () {} : () => _handleLogin(context),
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
                          onGoogleTap: isLoading
                              ? () {}
                              : () {
                                  context.read<LoginBloc>().add(const LoginWithGoogle());
                                },
                          onDiscordTap: isLoading ? () {} : _handleDiscordLogin,
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

  /// Show OTP dialog
  Future<void> _showOtpDialog(BuildContext context) async {
    final otpController = TextEditingController();

    return showDialog(
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
                  'Please enter the verification code sent to your email',
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
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.read<LoginBloc>().add(const LoginReset());
                        },
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
                            Navigator.of(dialogContext).pop();
                            context.read<LoginBloc>().add(VerifyEmailSubmitted(code));
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

  /// Show role selection dialog
  Future<void> _showRoleSelectionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return SelectRolePopup(
          onRoleSelected: (role) {
            Navigator.of(dialogContext).pop();
            context.read<LoginBloc>().add(SelectRoleSubmitted(role));
          },
        );
      },
    );
  }
}
