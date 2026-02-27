import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/forgot_password_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/forgot_password_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/forgot_password_usecase.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordUseCase forgotPasswordUseCase;

  ForgotPasswordBloc({
    required this.forgotPasswordUseCase,
  }) : super(const ForgotPasswordState()) {
    on<EmailChanged>(_onEmailChanged);
    on<SubmitForgotPassword>(_onSubmitForgotPassword);
  }

  void _onEmailChanged(EmailChanged event, Emitter<ForgotPasswordState> emit) {
    final email = event.email.trim();
    final emailError = _validateEmail(email);
    
    emit(state.copyWith(
      email: email,
      emailError: emailError,
    ));
  }

  Future<void> _onSubmitForgotPassword(
    SubmitForgotPassword event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final emailError = _validateEmail(state.email);
    
    if (emailError != null) {
      emit(state.copyWith(emailError: emailError));
      return;
    }

    emit(state.copyWith(status: ForgotPasswordStatus.loading));

    final result = await forgotPasswordUseCase(state.email);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ForgotPasswordStatus.success,
      )),
    );
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
