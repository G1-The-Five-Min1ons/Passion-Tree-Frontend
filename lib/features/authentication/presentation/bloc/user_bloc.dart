import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/user_event.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final IAuthRepository authRepository;

  UserBloc({required this.authRepository}) : super(const UserInitial()) {
    on<LoadUser>(_onLoadUser);
    on<UpdateUser>(_onUpdateUser);
    on<UpdateHeartCount>(_onUpdateHeartCount);
    on<ClearUser>(_onClearUser);
  }

  /// Load user data from repository
  Future<void> _onLoadUser(
    LoadUser event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    try {
      final userProfile = await authRepository.getProfile();
      emit(UserLoaded(userProfile.user));
    } catch (e) {
      emit(UserError('Failed to load user data: ${e.toString()}'));
    }
  }

  /// Update user data in state
  void _onUpdateUser(
    UpdateUser event,
    Emitter<UserState> emit,
  ) {
    emit(UserLoaded(event.user));
  }

  /// Update only heart count
  void _onUpdateHeartCount(
    UpdateHeartCount event,
    Emitter<UserState> emit,
  ) {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      final updatedUser = currentUser.copyWith(heartCount: event.heartCount);
      emit(UserLoaded(updatedUser));
    }
  }

  /// Clear user data (logout)
  void _onClearUser(
    ClearUser event,
    Emitter<UserState> emit,
  ) {
    emit(const UserUnauthenticated());
  }
}
