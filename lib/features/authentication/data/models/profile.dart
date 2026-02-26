import 'package:passion_tree_frontend/core/error/exceptions.dart';

class Profile {
  final String profileId;
  final String? avatarUrl;
  final String? rankName;
  final int learningStreak;
  final int learningCount;
  final String? location;
  final String? bio;
  final int level;
  final int xp;
  final int hourLearned;
  final String userId;

  Profile({
    required this.profileId,
    this.avatarUrl,
    this.rankName,
    required this.learningStreak,
    required this.learningCount,
    this.location,
    this.bio,
    required this.level,
    required this.xp,
    required this.hourLearned,
    required this.userId,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    try {
      return Profile(
        profileId: json['profile_id'] as String,
        avatarUrl: json['avatar_url'] as String?,
        rankName: json['rank_name'] as String?,
        learningStreak: json['learning_streak'] as int,
        learningCount: json['learning_count'] as int,
        location: json['location'] as String?,
        bio: json['bio'] as String?,
        level: json['level'] as int,
        xp: json['xp'] as int,
        hourLearned: json['hour_learned'] as int,
        userId: json['user_id'] as String,
      );
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse Profile',
        originalError: e,
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'profile_id': profileId,
    'avatar_url': avatarUrl,
    'rank_name': rankName,
    'learning_streak': learningStreak,
    'learning_count': learningCount,
    'location': location,
    'bio': bio,
    'level': level,
    'xp': xp,
    'hour_learned': hourLearned,
    'user_id': userId,
  };
}
