import 'package:passion_tree_frontend/features/authentication/data/models/user.dart' as model;
import 'package:passion_tree_frontend/features/authentication/data/models/profile.dart' as modelProfile;
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

  static Profile toProfileEntity(modelProfile.Profile profileModel) {
    return Profile(
      profileId: profileModel.profileId,
      avatarUrl: profileModel.avatarUrl,
      rankName: profileModel.rankName,
      learningStreak: profileModel.learningStreak,
      learningCount: profileModel.learningCount,
      location: profileModel.location,
      bio: profileModel.bio,
      level: profileModel.level,
      xp: profileModel.xp,
      hourLearned: profileModel.hourLearned,
      userId: profileModel.userId,
    );
  }
}
