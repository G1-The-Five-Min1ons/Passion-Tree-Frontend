import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/verify_email_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/verify_email_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/verify_email_usecase.dart';

class VerifyEmailBloc extends Bloc<VerifyEmailEvent, VerifyEmailState> {
  final VerifyEmailUseCase verifyEmailUseCase;

  VerifyEmailBloc({
    required this.verifyEmailUseCase,
  }) : super(const VerifyEmailState()) {
    on<OtpCodeChanged>(_onOtpCodeChanged);
    on<SubmitVerifyEmail>(_onSubmitVerifyEmail);
    on<CancelVerifyEmail>(_onCancelVerifyEmail);
  }

  void _onOtpCodeChanged(OtpCodeChanged event, Emitter<VerifyEmailState> emit) {
    final code = event.code.trim();
    final otpError = _validateOtpCode(code);

    emit(state.copyWith(
      otpCode: code,
      otpError: otpError,
    ));
  }

  Future<void> _onSubmitVerifyEmail(
    SubmitVerifyEmail event,
    Emitter<VerifyEmailState> emit,
  ) async {
    final otpError = _validateOtpCode(state.otpCode);

    if (otpError != null) {
      emit(state.copyWith(otpError: otpError));
      return;
    }

    emit(state.copyWith(status: VerifyEmailStatus.loading));

    final result = await verifyEmailUseCase.execute(state.otpCode);

    result.fold(
      (failure) => emit(state.copyWith(
        status: VerifyEmailStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: VerifyEmailStatus.success,
      )),
    );
  }

  void _onCancelVerifyEmail(
    CancelVerifyEmail event,
    Emitter<VerifyEmailState> emit,
  ) {
    emit(state.copyWith(status: VerifyEmailStatus.cancelled));
  }

  String? _validateOtpCode(String value) {
    if (value.isEmpty) {
      return 'Verification code is required';
    }
    if (value.length != 6) {
      return 'Code must be 6 digits';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Code must contain only digits';
    }
    return null;
  }
}
