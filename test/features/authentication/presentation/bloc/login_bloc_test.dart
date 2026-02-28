import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/login_state.dart';

// Mock AuthRepository
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('LoginBloc', () {
    test('initial state is LoginState()', () {
      final bloc = LoginBloc(authRepository: mockAuthRepository);
      expect(bloc.state, const LoginState());
    });

    blocTest<LoginBloc, LoginState>(
      'emits [LoginState] with updated username when LoginUsernameChanged is added',
      build: () => LoginBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const LoginUsernameChanged('testuser')),
      expect: () => [
        const LoginState(username: 'testuser'),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [LoginState] with updated password when LoginPasswordChanged is added',
      build: () => LoginBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const LoginPasswordChanged('password')),
      expect: () => [
        const LoginState(password: 'password'),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [loading, success] when login succeeds',
      setUp: () {
        when(() => mockAuthRepository.login(
              identifier: 'user',
              password: 'pass',
            )).thenAnswer((_) async => 'Login successful');
      },
      build: () => LoginBloc(authRepository: mockAuthRepository),
      seed: () => const LoginState(username: 'user', password: 'pass'), // Pre-fill state
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        const LoginState(username: 'user', password: 'pass', status: LoginStatus.loading),
        const LoginState(username: 'user', password: 'pass', status: LoginStatus.success),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [loading, failure] when login fails',
      setUp: () {
        when(() => mockAuthRepository.login(
              identifier: 'user',
              password: 'pass',
            )).thenThrow(Exception('Login failed'));
      },
      build: () => LoginBloc(authRepository: mockAuthRepository),
      seed: () => const LoginState(username: 'user', password: 'pass'),
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        const LoginState(username: 'user', password: 'pass', status: LoginStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', contains('Login failed')),
      ],
    );
  });
}
