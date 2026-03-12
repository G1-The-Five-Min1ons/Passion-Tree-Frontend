import 'package:passion_tree_frontend/core/error/exceptions.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/authentication/data/models/user.dart'
    as model;
import 'package:passion_tree_frontend/features/authentication/data/models/profile.dart'
    as modelProfile;
import 'package:passion_tree_frontend/features/authentication/domain/entities/user.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/profile.dart';
import 'package:passion_tree_frontend/features/authentication/domain/entities/user_profile.dart';

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
      phoneNumber: profileModel.phoneNumber,
      level: profileModel.level,
      xp: profileModel.xp,
      hourLearned: profileModel.hourLearned,
      userId: profileModel.userId,
    );
  }

  static UserProfile toUserProfileEntity(Map<String, dynamic> responseMap) {
    final data = _extractDataField(responseMap);
    final user = _parseUser(data);
    final profile = _parseProfile(data);

    return UserProfile(user: user, profile: profile);
  }

  static Map<String, dynamic> _extractDataField(Map<String, dynamic> response) {
    if (!response.containsKey('data') || response['data'] == null) {
      throw ParseException(
        message: 'Missing or null "data" field in getProfile response',
      );
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw ParseException(
        message: 'Expected Map<String, dynamic> for "data" but got ${data.runtimeType}',
      );
    }

    return data;
  }

  static User _parseUser(Map<String, dynamic> data) {
    if (!data.containsKey('user') || data['user'] == null) {
      throw ParseException(
        message: 'Missing or null "user" field in response data',
      );
    }

    final userJson = data['user'];
    if (userJson is! Map<String, dynamic>) {
      throw ParseException(
        message: 'Expected Map<String, dynamic> for "user" but got ${userJson.runtimeType}',
      );
    }

    final userModel = model.User.fromJson(userJson);
    return toUserEntity(userModel);
  }

  static Profile? _parseProfile(Map<String, dynamic> data) {
    if (!data.containsKey('profile') || data['profile'] == null) {
      return null;
    }

    final profileJson = data['profile'];
    if (profileJson is! Map<String, dynamic>) {
      LogHandler.error('Expected Map<String, dynamic> for profile but got ${profileJson.runtimeType}');
      return null;
    }

    try {
      final profileModel = modelProfile.Profile.fromJson(profileJson);
      return toProfileEntity(profileModel);
    } catch (e) {
      LogHandler.error('Failed to parse profile data. Error: $e');
      return null;
    }
  }
}
