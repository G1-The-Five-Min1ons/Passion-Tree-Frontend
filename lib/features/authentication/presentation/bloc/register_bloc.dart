import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/register_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/register_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/register_user_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/login_with_credentials_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/verify_email_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_user_role_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_profile_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/select_role_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/mark_role_selected_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/save_user_role_usecase.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUserUseCase registerUserUseCase;
  final LoginWithCredentialsUseCase loginWithCredentialsUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final GetUserRoleUseCase getUserRoleUseCase;
  final GetProfileUseCase getProfileUseCase;
  final SelectRoleUseCase selectRoleUseCase;
  final MarkRoleSelectedUseCase markRoleSelectedUseCase;
  final SaveUserRoleUseCase saveUserRoleUseCase;

  RegisterBloc({
    required this.registerUserUseCase,
    required this.loginWithCredentialsUseCase,
    required this.verifyEmailUseCase,
    required this.getUserRoleUseCase,
    required this.getProfileUseCase,
    required this.selectRoleUseCase,
    required this.markRoleSelectedUseCase,
    required this.saveUserRoleUseCase,
  }) : super(const RegisterState()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<RegisterReset>(_onRegisterReset);
    on<AutoLoginAfterRegister>(_onAutoLoginAfterRegister);
    on<VerifyEmailAfterRegister>(_onVerifyEmailAfterRegister);
    on<SyncRoleAfterRegister>(_onSyncRoleAfterRegister);
    on<CompleteRegistrationFlow>(_onCompleteRegistrationFlow);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading));

    final result = await registerUserUseCase.execute(
      username: event.username,
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
      role: event.role,
      bio: event.bio,
      location: event.location,
      avatarUrl: event.avatarUrl,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: failure.message,
      )),
      (userId) => emit(state.copyWith(
        status: RegisterStatus.success,
        userId: userId,
        nextStep: RegisterNextStep.complete,
        successMessage: 'Registration successful! Please sign in.',
      )),
    );
  }

  Future<void> _onAutoLoginAfterRegister(
    AutoLoginAfterRegister event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading));

    // Auto-login
    final loginResult = await loginWithCredentialsUseCase.execute(
      identifier: event.username,
      password: event.password,
    );

    loginResult.fold(
      (failure) => emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: failure.message,
      )),
      (token) => emit(state.copyWith(
        status: RegisterStatus.success,
        token: token,
        nextStep: RegisterNextStep.otpVerification,
        successMessage: 'Auto-login successful. Please verify your email.',
      )),
    );
  }

  Future<void> _onVerifyEmailAfterRegister(
    VerifyEmailAfterRegister event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading));

    final result = await verifyEmailUseCase.execute(event.otpCode);

    result.fold(
      (failure) => emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: RegisterStatus.success,
        nextStep: RegisterNextStep.roleSync,
        successMessage: 'Email verified successfully',
      )),
    );
  }

  Future<void> _onSyncRoleAfterRegister(
    SyncRoleAfterRegister event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading));

    // Get local role
    final localRoleResult = await getUserRoleUseCase.execute();
    String? localRole;
    localRoleResult.fold(
      (failure) => null,
      (role) => localRole = role,
    );

    // Get profile from backend
    final profileResult = await getProfileUseCase.execute();
    await profileResult.fold(
      (failure) async {
        emit(state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (userProfile) async {
        final backendRole = userProfile.user.role;

        // Sync role if needed
        if (backendRole == 'pending' &&
            localRole != null &&
            (localRole == 'student' || localRole == 'teacher')) {
          final syncResult = await selectRoleUseCase.execute(localRole!);
          syncResult.fold(
            (failure) => emit(state.copyWith(
              status: RegisterStatus.failure,
              errorMessage: 'Failed to sync role: ${failure.message}',
            )),
            (_) => emit(state.copyWith(
              status: RegisterStatus.success,
              nextStep: RegisterNextStep.complete,
              successMessage: 'Role synced successfully',
            )),
          );
        } else {
          emit(state.copyWith(
            status: RegisterStatus.success,
            nextStep: RegisterNextStep.complete,
            successMessage: 'Registration flow complete',
          ));
        }
      },
    );
  }

  void _onCompleteRegistrationFlow(
    CompleteRegistrationFlow event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      status: RegisterStatus.success,
      nextStep: RegisterNextStep.complete,
    ));
  }

  void _onRegisterReset(
    RegisterReset event,
    Emitter<RegisterState> emit,
  ) {
    emit(const RegisterState());
  }
}
