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
      (userId) => emit(RegisterSuccess(
        userId: userId,
        token: '', // Token handled by repo or ignored
        message: 'Registration successful',
      )),
    );
  }

  /// Handle registration reset
  void _onRegisterReset(
    RegisterReset event,
    Emitter<RegisterState> emit,
  ) {
    emit(const RegisterInitial());
  }
}
