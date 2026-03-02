import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/reset_password_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/reset_password_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/reset_password_usecase.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final ResetPasswordUseCase resetPasswordUseCase;

  ResetPasswordBloc({
    required this.resetPasswordUseCase,
  }) : super(const ResetPasswordState()) {
    on<CodeChanged>(_onCodeChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<ConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SubmitResetPassword>(_onSubmitResetPassword);
  }

  void _onCodeChanged(CodeChanged event, Emitter<ResetPasswordState> emit) {
    final code = event.code.trim();
    final codeError = _validateCode(code);

    emit(state.copyWith(
      code: code,
      codeError: codeError,
    ));
  }

  void _onPasswordChanged(
      PasswordChanged event, Emitter<ResetPasswordState> emit) {
    final password = event.password;
    final passwordError = _validatePassword(password);

    // Re-validate confirm password if it's not empty
    String? confirmPasswordError;
    if (state.confirmPassword.isNotEmpty) {
      confirmPasswordError = _validateConfirmPassword(
        state.confirmPassword,
        password,
      );
    }

    emit(state.copyWith(
      password: password,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
    ));
  }

  void _onConfirmPasswordChanged(
      ConfirmPasswordChanged event, Emitter<ResetPasswordState> emit) {
    final confirmPassword = event.confirmPassword;
    final confirmPasswordError = _validateConfirmPassword(
      confirmPassword,
      state.password,
    );

    emit(state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: confirmPasswordError,
    ));
  }

  Future<void> _onSubmitResetPassword(
    SubmitResetPassword event,
    Emitter<ResetPasswordState> emit,
  ) async {
    // Validate all fields
    final codeError = _validateCode(state.code);
    final passwordError = _validatePassword(state.password);
    final confirmPasswordError = _validateConfirmPassword(
      state.confirmPassword,
      state.password,
    );

    if (codeError != null || passwordError != null || confirmPasswordError != null) {
      emit(state.copyWith(
        codeError: codeError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
      ));
      return;
    }

    emit(state.copyWith(status: ResetPasswordStatus.loading));

    final result = await resetPasswordUseCase(
      code: state.code,
      newPassword: state.password,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ResetPasswordStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ResetPasswordStatus.success,
      )),
    );
  }

  String? _validateCode(String value) {
    if (value.isEmpty) {
      return 'Reset code is required';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String confirmPassword, String password) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmPassword != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
