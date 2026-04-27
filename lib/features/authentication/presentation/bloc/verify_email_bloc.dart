import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/resend_verification_email_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/verify_email_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/verify_email_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/verify_email_usecase.dart';

class VerifyEmailBloc extends Bloc<VerifyEmailEvent, VerifyEmailState> {
  final VerifyEmailUseCase verifyEmailUseCase;
  final ResendVerificationEmailUseCase resendVerificationEmailUseCase;

  VerifyEmailBloc({
    required this.verifyEmailUseCase,
    required this.resendVerificationEmailUseCase,
    String? initialResendEmail,
  }) : super(
         VerifyEmailState(resendEmail: initialResendEmail?.trim() ?? ''),
       ) {
    on<OtpCodeChanged>(_onOtpCodeChanged);
    on<ResendEmailChanged>(_onResendEmailChanged);
    on<SubmitVerifyEmail>(_onSubmitVerifyEmail);
    on<ResendVerificationEmailRequested>(_onResendVerificationEmailRequested);
    on<CancelVerifyEmail>(_onCancelVerifyEmail);
  }

  void _onOtpCodeChanged(OtpCodeChanged event, Emitter<VerifyEmailState> emit) {
    final code = event.code.trim();
    final otpError = _validateOtpCode(code);

    emit(state.copyWith(
      otpCode: code,
      otpError: otpError,
      status: VerifyEmailStatus.initial,
      errorMessage: null,
    ));
  }

  void _onResendEmailChanged(
    ResendEmailChanged event,
    Emitter<VerifyEmailState> emit,
  ) {
    final email = event.email.trim();

    emit(state.copyWith(
      resendEmail: email,
      resendEmailError: _validateResendEmail(email),
      resendStatus: ResendVerificationStatus.initial,
      resendMessage: null,
    ));
  }

  Future<void> _onSubmitVerifyEmail(
    SubmitVerifyEmail event,
    Emitter<VerifyEmailState> emit,
  ) async {
    final otpError = _validateOtpCode(state.otpCode);

    if (otpError != null) {
      emit(state.copyWith(
        otpError: otpError,
        status: VerifyEmailStatus.failure,
        errorMessage: null,
      ));
      return;
    }

    emit(state.copyWith(
      status: VerifyEmailStatus.loading,
      otpError: null,
      errorMessage: null,
    ));

    final result = await verifyEmailUseCase.execute(state.otpCode);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: VerifyEmailStatus.failure,
          otpError: failure.message,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(
        status: VerifyEmailStatus.success,
        otpError: null,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onResendVerificationEmailRequested(
    ResendVerificationEmailRequested event,
    Emitter<VerifyEmailState> emit,
  ) async {
    final resendEmailError = _validateResendEmail(state.resendEmail);

    if (resendEmailError != null) {
      emit(state.copyWith(
        resendEmailError: resendEmailError,
        resendStatus: ResendVerificationStatus.failure,
        resendMessage: null,
      ));
      return;
    }

    emit(state.copyWith(
      resendStatus: ResendVerificationStatus.loading,
      resendEmailError: null,
      resendMessage: null,
    ));

    final result = await resendVerificationEmailUseCase.execute(state.resendEmail);

    result.fold(
      (failure) => emit(
        state.copyWith(
          resendStatus: ResendVerificationStatus.failure,
          resendMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          resendStatus: ResendVerificationStatus.success,
          resendMessage: 'Verification code sent successfully',
        ),
      ),
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

  String? _validateResendEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required to resend the code';
    }

    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }
}
