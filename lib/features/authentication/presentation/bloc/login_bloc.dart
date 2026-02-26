import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/login_with_credentials_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/login_with_google_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/login_with_discord_usecase.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required LoginWithCredentialsUseCase loginWithCredentials,
    required LoginWithGoogleUseCase loginWithGoogle,
    required LoginWithDiscordUseCase loginWithDiscord,
  })  : _loginWithCredentials = loginWithCredentials,
        _loginWithGoogle = loginWithGoogle,
        _loginWithDiscord = loginWithDiscord,
        super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginRememberMeToggled>(_onRememberMeToggled);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<LoginWithDiscord>(_onLoginWithDiscord);
    on<LoginWithDiscordCode>(_onLoginWithDiscordCode);
  }

  final LoginWithCredentialsUseCase _loginWithCredentials;
  final LoginWithGoogleUseCase _loginWithGoogle;
  final LoginWithDiscordUseCase _loginWithDiscord;

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

    final result = await _loginWithCredentials.execute(
      identifier: state.username,
      password: state.password,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: LoginStatus.success)),
    );
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogle event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    final result = await _loginWithGoogle.execute();

    result.fold(
      (failure) {
        // User cancellation - return to initial state
        if (failure is CancellationFailure) {
          emit(state.copyWith(status: LoginStatus.initial));
        } else {
          emit(state.copyWith(
            status: LoginStatus.failure,
            errorMessage: failure.message,
          ));
        }
      },
      (_) => emit(state.copyWith(status: LoginStatus.success)),
    );
  }

  Future<void> _onLoginWithDiscord(
    LoginWithDiscord event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    final result = await _loginWithDiscord.initiateOAuth();

    result.fold(
      (failure) => emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => {
        // Keep loading state while waiting for callback
      },
    );
  }

  Future<void> _onLoginWithDiscordCode(
    LoginWithDiscordCode event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    final result = await _loginWithDiscord.authenticateWithCode(event.code);

    result.fold(
      (failure) => emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: LoginStatus.success)),
    );
  }
}