import 'package:equatable/equatable.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/user.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/profile.dart';

/// Combined entity for user and profile data
class UserProfile extends Equatable {
  final User user;
  final Profile? profile;

  const UserProfile({
    required this.user,
    this.profile,
  });

  @override
  List<Object?> get props => [user, profile];

  UserProfile copyWith({
    User? user,
    Profile? profile,
  }) {
    return UserProfile(
      user: user ?? this.user,
      profile: profile ?? this.profile,
    );
  }
}
