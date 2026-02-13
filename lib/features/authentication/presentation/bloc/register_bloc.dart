import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/auth_models.dart';
import 'package:passion_tree_frontend/features/authentication/data/services/auth_api_service.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/register_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthApiService _authApiService;

  RegisterBloc({
    required AuthApiService authApiService,
  })  : _authApiService = authApiService,
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
      // Create registration request
      final request = RegisterRequest(
        username: event.username,
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        bio: event.bio,
        location: event.location,
        avatarUrl: event.avatarUrl,
      );

      final response = await _authApiService.register(request);

      emit(RegisterSuccess(
        userId: response.userId,
        token: response.token,
        message: response.message,
      ));
    } on AuthException catch (e) {
      // Handle auth-specific errors
      emit(RegisterFailure(
        error: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      // Handle generic errors
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

  @override
  Future<void> close() {
    _authApiService.dispose();
    return super.close();
  }
}
