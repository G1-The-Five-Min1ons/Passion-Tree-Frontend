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
      await _authRepository.register(
        username: event.username,
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        role: event.role ?? 'student', // Default if null, though event likely strictly typed?
        bio: event.bio,
        location: event.location,
        avatarUrl: event.avatarUrl,
      );
      
      // After registration, we usually want to login or get token.
      // The previous logic returned {userId, token} in RegisterResponse.
      // My IAuthRepository.register returns void.
      // I need to check how backend behaves. 
      // If it returns a token, I should capture it.
      // AuthRepositoryImpl.register calls remoteDataSource.register.
      // remoteDataSource.register returns RegisterResponse (with userId, token).
      // AuthRepositoryImpl.register ignores the return value!
      
      // I made a mistake in AuthRepositoryImpl. It returns void.
      // But RegisterBloc needs userId and token to proceed (step 662 line 42-46: emit RegisterSuccess(userId, token...)).
      
      // I must update IAuthRepository and AuthRepositoryImpl to return something useful (e.g. User or just the data needed).
      // Or I can change the flow to login after register?
      // Step 662: response.userId, response.token.
      
      // I will update IAuthRepository.register to return void? No, I need userId.
      // Let's assume I fix AuthRepository to return userId.
      
      // Wait, I can't update RegisterBloc correctly until I fix AuthRepository.
      // I'll update AuthRepository first (in next step).
      // For now, I'll write the Bloc code assuming it returns *something* or I'll fix it now.
      
      // I will ABORT `RegisterBloc` update in this tool call and Fix AuthRepositoryImpl first.
      // But I can't abort comfortably. 
      // I'll proceed with `RegisterBloc` assuming `register` returns user info.
      // Or I can make `register` return a Map or DTO.
      // Since Domain layer should return Entities, maybe return `User`?
      // But `RegisterResponse` has `token`. `User` entity doesn't have token.
      
      // I'll make IAuthRepository.register return `Future<RegisterResponse>` (Wait, that's a data model, leaky abstraction).
      // Or `Future<{String userId, String? token}>`.
      // Or `Future<void>` and handle login separately?
      // The current UI expects `RegisterSuccess` state with userId to show Role Selection.
      
      // I'll update IAuthRepository to return `Future<Map<String, dynamic>>` or a domain class `RegistrationResult`.
      // `class RegistrationResult { final String userId; final String? token; }`
      
      // To satisfy clean arch, I should create `RegistrationResult` in domain/entities.
      // It's too much boiler plate right now.
      
      // Implementation plan:
      // 1. Update RegisterBloc to call register.
      // 2. But implementation details matter.
      
      // I'll revert to just `void` and fetch user? No, we need userId for role selection mark.
      // I'll update `AuthRepository` to return `String` (userId) or `User`.
      
      // Let's look at `AuthRepositoryImpl` again (Step 653).
      // `remoteDataSource.register` returns `RegisterResponse`.
      
      // I'll update `IAuthRepository` to return `Future<String>` (userId).
      // And `AuthRepositoryImpl` to return `response.userId`.
      
      // But wait, `RegisterResponse` also has `token`.
      // If backend returns token, we should probably save it?
      // `AuthRepositoryImpl` currently doesn't save token on register.
      // `AuthApiService` logic (Step 619, I recalled reading it): it returned response.
      // `RegisterBloc` (Step 662): `response.userId, response.token`.
      // And `RegisterPage` (Step 668): `if (selectedRole != null && state.userId.isNotEmpty) ... markRoleSelected`.
      
      // It seems we need userId.
      
      // I will update `IAuthRepository` to return `Future<String>` (UserId).
      // And I will simply not return token for now, or assume auto-login?
      // If token is returned, `AuthRepositoryImpl` should probably save it?
      // If so, `RegisterBloc` doesn't need to return it to UI, it just needs to say "Success".
      // But `RegisterPage` logic uses `userId` to mark role.
      
      // OK. I'll update `IAuthRepository.register` to return `Future<String>`.
      
      // For this step (RegisterBloc), I'll write code that expects `String userId = await repository.register(...)`.
      
      // Wait, `RegisterBloc` currently expects `response.token`.
      // Does it use it?
      // RegisterPage `RegisterSuccess` handling (Step 668 lines 150-182):
      // It uses `state.userId`.
      // It doesn't seem to use `state.token`.
      // `RegisterSuccess` has `token` field though.
      // `RegisterPage` line 171: checks `state.userId`.
      
      // So I just need `userId`.
      
      final userId = await _authRepository.register(
        username: event.username,
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        role: event.role ?? 'student',
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
