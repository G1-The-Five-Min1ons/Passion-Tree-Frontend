import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required IAuthRepository authRepository})
      : _authRepository = authRepository,
        super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginRememberMeToggled>(_onRememberMeToggled);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<LoginWithDiscord>(_onLoginWithDiscord);
    on<LoginWithDiscordCode>(_onLoginWithDiscordCode);
  }

  final IAuthRepository _authRepository;

  void _onUsernameChanged(
    LoginUsernameChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(username: event.username));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  void _onRememberMeToggled(
    LoginRememberMeToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(rememberMe: event.rememberMe));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      final message = await _authRepository.login(
        identifier: state.username,
        password: state.password,
      );
      // Login successful, but might need OTP. 
      // For now assuming success leads to OTP page or similar.
      // The state.success normally navigates away.
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogle event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      // Google SignIn v7 migration
      final account = await GoogleSignIn.instance.authenticate();
      if (account == null) {
        emit(state.copyWith(status: LoginStatus.initial)); // User cancelled
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken != null) {
        await _authRepository.nativeGoogleSignIn(idToken);
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        throw Exception('Failed to retrieve Google ID Token');
      }
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Google login failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoginWithDiscord(
    LoginWithDiscord event,
    Emitter<LoginState> emit,
  ) async {
    // Discord OAuth2 URL
    // TODO: Replace with actual Client ID and Redirect URI from environment/config
    const clientId = 'YOUR_DISCORD_CLIENT_ID'; 
    const redirectUri = 'passiontree://auth/callback';
    const scope = 'identify email connections guild.join';
    
    final url = Uri.parse(
      'https://discord.com/api/oauth2/authorize?client_id=$clientId&redirect_uri=$redirectUri&response_type=code&scope=$scope',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        // We don't change state to success here; we wait for the callback (deep link)
        // possibly set status to loading?
        emit(state.copyWith(status: LoginStatus.loading)); 
      } else {
        throw Exception('Could not launch Discord login');
      }
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Discord login failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoginWithDiscordCode(
    LoginWithDiscordCode event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      await _authRepository.nativeDiscordSignIn(event.code);
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Discord login failed: ${e.toString()}',
      ));
    }
  }
}
