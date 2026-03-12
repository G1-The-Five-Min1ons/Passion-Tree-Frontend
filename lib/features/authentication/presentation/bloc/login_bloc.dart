import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/login_with_credentials_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/login_with_google_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/login_with_discord_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/verify_email_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_profile_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/select_role_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_user_role_usecase.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required LoginWithCredentialsUseCase loginWithCredentials,
    required LoginWithGoogleUseCase loginWithGoogle,
    required LoginWithDiscordUseCase loginWithDiscord,
    required VerifyEmailUseCase verifyEmail,
    required GetProfileUseCase getProfile,
    required SelectRoleUseCase selectRole,
    required GetUserRoleUseCase getUserRole,
  }) : _loginWithCredentials = loginWithCredentials,
       _loginWithGoogle = loginWithGoogle,
       _loginWithDiscord = loginWithDiscord,
       _verifyEmail = verifyEmail,
       _getProfile = getProfile,
       _selectRole = selectRole,
       _getUserRole = getUserRole,
       super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginRememberMeToggled>(_onRememberMeToggled);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<LoginWithDiscord>(_onLoginWithDiscord);
    on<LoginWithDiscordCode>(_onLoginWithDiscordCode);
    on<VerifyEmailSubmitted>(_onVerifyEmailSubmitted);
    on<CheckRoleStatus>(_onCheckRoleStatus);
    on<SelectRoleSubmitted>(_onSelectRoleSubmitted);
    on<LoginReset>(_onLoginReset);
  }

  final LoginWithCredentialsUseCase _loginWithCredentials;
  final LoginWithGoogleUseCase _loginWithGoogle;
  final LoginWithDiscordUseCase _loginWithDiscord;
  final VerifyEmailUseCase _verifyEmail;
  final GetProfileUseCase _getProfile;
  final SelectRoleUseCase _selectRole;
  final GetUserRoleUseCase _getUserRole;

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
      (failure) {
        if (_isOtpVerificationRequired(failure.message)) {
          emit(state.copyWith(
            status: LoginStatus.success,
            nextStep: LoginNextStep.otpVerification,
            errorMessage: null,
          ));
          return;
        }

        emit(state.copyWith(
          status: LoginStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (_) => emit(state.copyWith(
        status: LoginStatus.success,
        nextStep: LoginNextStep.otpVerification,
      )),
    );
  }

  bool _isOtpVerificationRequired(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('verification_required') ||
        normalized.contains('6-digit code') ||
        normalized.contains('otp');
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
          emit(
            state.copyWith(
              status: LoginStatus.failure,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (_) => emit(
        state.copyWith(
          status: LoginStatus.success,
          nextStep: LoginNextStep.checkingRole,
        ),
      ),
    );
  }

  Future<void> _onLoginWithDiscord(
    LoginWithDiscord event,
    Emitter<LoginState> emit,
  ) async {
    LogHandler.info('[LoginBloc] _onLoginWithDiscord: START');
    emit(state.copyWith(status: LoginStatus.loading));

    final result = await _loginWithDiscord.initiateOAuth();
    LogHandler.info(
      '[LoginBloc] initiateOAuth() returned. IsRight: ${result.isRight()}',
    );

    result.fold(
      (failure) {
        LogHandler.error('[LoginBloc] initiateOAuth FAILED: ${failure.message}');
        if (failure is CancellationFailure) {
          emit(state.copyWith(status: LoginStatus.initial));
        } else {
          emit(
            state.copyWith(
              status: LoginStatus.failure,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (_) {
        LogHandler.info(
          '[LoginBloc] initiateOAuth SUCCESS -> emitting (success, checkingRole)',
        );
        emit(
          state.copyWith(
            status: LoginStatus.success,
            nextStep: LoginNextStep.checkingRole,
          ),
        );
        LogHandler.info(
          '[LoginBloc] Emitted (success, checkingRole). Current state: ${state.status}, ${state.nextStep}',
        );
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
      (failure) => emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: LoginStatus.success,
          nextStep: LoginNextStep.checkingRole,
        ),
      ),
    );
  }

  Future<void> _onVerifyEmailSubmitted(
    VerifyEmailSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    final result = await _verifyEmail.execute(event.code);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            status: LoginStatus.success,
            nextStep: LoginNextStep.checkingRole,
          ),
        );
      },
    );
  }

  Future<void> _onCheckRoleStatus(
    CheckRoleStatus event,
    Emitter<LoginState> emit,
  ) async {
    LogHandler.info('[LoginBloc] _onCheckRoleStatus: START');
    emit(state.copyWith(status: LoginStatus.loading));

    // Get local role first
    final localRoleResult = await _getUserRole.execute();
    String? localRole;

    localRoleResult.fold((failure) => null, (role) => localRole = role);
    LogHandler.info('[LoginBloc] localRole: $localRole');

    // Get profile from backend
    LogHandler.info('[LoginBloc] Fetching profile from backend...');
    final profileResult = await _getProfile.execute();
    LogHandler.info(
      '[LoginBloc] _getProfile.execute() returned. IsRight: ${profileResult.isRight()}',
    );

    profileResult.fold(
      (failure) {
        LogHandler.error('[LoginBloc] getProfile FAILED: ${failure.message}');
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (profile) {
        final backendRole = profile.user.role;
        LogHandler.info(
          '[LoginBloc] Profile fetched. backendRole: $backendRole',
        );

        // Determine next step based on role
        if (backendRole == 'pending') {
          LogHandler.info(
            '[LoginBloc] Role is pending -> emitting (success, roleSelection)',
          );
          emit(
            state.copyWith(
              status: LoginStatus.success,
              nextStep: LoginNextStep.roleSelection,
            ),
          );
        } else {
          LogHandler.info(
            '[LoginBloc] Role is set ($backendRole) -> emitting (success, complete)',
          );
          emit(
            state.copyWith(
              status: LoginStatus.success,
              nextStep: LoginNextStep.complete,
            ),
          );
        }
      },
    );
  }

  Future<void> _onSelectRoleSubmitted(
    SelectRoleSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    final result = await _selectRole.execute(event.role);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: LoginStatus.success,
          nextStep: LoginNextStep.complete,
        ),
      ),
    );
  }

  void _onLoginReset(LoginReset event, Emitter<LoginState> emit) {
    emit(const LoginState());
  }
}
