import 'package:equatable/equatable.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no user loaded
class UserInitial extends UserState {
  const UserInitial();
}

/// Loading user data
class UserLoading extends UserState {
  const UserLoading();
}

/// User data loaded successfully
class UserLoaded extends UserState {
  final User user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];

  /// Helper getter for heart count
  int get heartCount => user.heartCount;

  UserLoaded copyWith({User? user}) {
    return UserLoaded(user ?? this.user);
  }
}

/// Error loading user data
class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

/// User logged out / cleared
class UserUnauthenticated extends UserState {
  const UserUnauthenticated();
}
