import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/error/exceptions.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/register_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/register_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final IAuthRepository _authRepository;

  RegisterBloc({
    required IAuthRepository authRepository,
  })  : _authRepository = authRepository,
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

    try {
      final userId = await _authRepository.register(
        username: event.username,
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        bio: event.bio,
        location: event.location,
        avatarUrl: event.avatarUrl,
      );

      emit(RegisterSuccess(
        userId: userId,
        token: '', // Token handled by repo or ignored
        message: 'Registration successful',
      ));
    } on AuthException catch (e) {
      emit(RegisterFailure(
        error: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      emit(RegisterFailure(
        error: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Handle registration reset
  void _onRegisterReset(
    RegisterReset event,
    Emitter<RegisterState> emit,
  ) {
    emit(const RegisterInitial());
  }
}
