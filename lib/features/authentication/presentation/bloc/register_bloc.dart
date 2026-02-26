import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/register_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/register_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/register_user_usecase.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUserUseCase _registerUser;

  RegisterBloc({
    required RegisterUserUseCase registerUser,
  })  : _registerUser = registerUser,
        super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<RegisterReset>(_onRegisterReset);
  }

  /// Handle registration submission
  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());

    final result = await _registerUser.execute(
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
      (failure) => emit(RegisterFailure(
        error: failure.message,
        statusCode: null,
      )),
      (userId) {
        // Determine next step based on role
        final nextStep = _determineNextStep(event.role);
        
        emit(RegisterSuccess(
          userId: userId,
          token: '',
          message: 'Registration successful',
          nextStep: nextStep,
        ));
      },
    );
  }

  /// Determine the next step after registration based on role
  RegisterNextStep _determineNextStep(String role) {
    // If role is pending, user needs to select their actual role
    if (role.toLowerCase() == 'pending') {
      return RegisterNextStep.roleSelection;
    }
    
    // If role is already set (student/teacher), proceed to OTP verification
    return RegisterNextStep.otpVerification;
  }

  /// Handle registration reset
  void _onRegisterReset(
    RegisterReset event,
    Emitter<RegisterState> emit,
  ) {
    emit(const RegisterInitial());
  }
}
