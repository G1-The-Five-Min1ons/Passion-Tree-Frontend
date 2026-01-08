import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginRememberMeToggled>(_onRememberMeToggled);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<LoginWithDiscord>(_onLoginWithDiscord);
  }

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
      // TODO: Implement actual authentication logic
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful login
      if (state.username.isNotEmpty && state.password.isNotEmpty) {
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Username and password are required',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Login failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogle event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      // TODO: Implement Google OAuth
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: LoginStatus.success));
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
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      // TODO: Implement Discord OAuth
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Discord login failed: ${e.toString()}',
      ));
    }
  }
}
