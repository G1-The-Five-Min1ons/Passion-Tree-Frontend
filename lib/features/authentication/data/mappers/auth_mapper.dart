import 'package:passion_tree_frontend/features/authentication/data/models/auth_models.dart' as model;
import 'package:passion_tree_frontend/features/authentication/domain/entities/user.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/profile.dart';

class AuthMapper {
  static User toUserEntity(model.User model) {
    return User(
      userId: model.userId,
      username: model.username,
      email: model.email,
      firstName: model.firstName,
      lastName: model.lastName,
      role: model.role,
      heartCount: model.heartCount,
      isEmailVerified: model.isEmailVerified,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static Profile toProfileEntity(model.Profile model) {
    return Profile(
      profileId: model.profileId,
      avatarUrl: model.avatarUrl,
      rankName: model.rankName,
      learningStreak: model.learningStreak,
      learningCount: model.learningCount,
      location: model.location,
      bio: model.bio,
      level: model.level,
      xp: model.xp,
      hourLearned: model.hourLearned,
      userId: model.userId,
    );
  }
}
