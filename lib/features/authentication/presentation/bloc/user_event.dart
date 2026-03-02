import 'package:equatable/equatable.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUser extends UserEvent {
  final String userId;

  const LoadUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to update user data in state
class UpdateUser extends UserEvent {
  final User user;

  const UpdateUser(this.user);

  @override
  List<Object?> get props => [user];
}

/// Event to update heart count
class UpdateHeartCount extends UserEvent {
  final int heartCount;

  const UpdateHeartCount(this.heartCount);

  @override
  List<Object?> get props => [heartCount];
}

/// Event to clear user data (e.g., on logout)
class ClearUser extends UserEvent {
  const ClearUser();
}
