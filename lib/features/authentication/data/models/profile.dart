import 'package:passion_tree_frontend/core/error/exceptions.dart';

class Profile {
  final String profileId;
  final String? avatarUrl;
  final String? rankName;
  final int learningStreak;
  final int learningCount;
  final String? location;
  final String? bio;
  final String? phoneNumber;
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
    this.phoneNumber,
    required this.level,
    required this.xp,
    required this.hourLearned,
    required this.userId,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    try {
      // Validate required fields
      final profileId = json['profile_id'] as String?;
      final userId = json['user_id'] as String?;

      if (profileId == null || profileId.isEmpty) {
        throw ParseException(
          message: 'Profile ID is required but was null or empty',
        );
      }

      if (userId == null || userId.isEmpty) {
        throw ParseException(
          message: 'User ID is required but was null or empty',
        );
      }

      return Profile(
        profileId: profileId,
        avatarUrl: json['avatar_url'] as String?,
        rankName: json['rank_name'] as String?,
        learningStreak: _parseIntField(json, 'learning_streak'),
        learningCount: _parseIntField(json, 'learning_count'),
        location: json['location'] as String?,
        bio: json['bio'] as String?,
        phoneNumber: json['phone_number'] as String?,
        level: _parseIntField(json, 'level'),
        xp: _parseIntField(json, 'xp'),
        hourLearned: _parseIntField(json, 'hour_learned'),
        userId: userId,
      );
    } catch (e) {
      if (e is ParseException) rethrow;
      throw ParseException(
        message: 'Failed to parse Profile',
        originalError: e,
      );
    }
  }

  static int _parseIntField(Map<String, dynamic> json, String fieldName) {
    final value = json[fieldName];
    if (value == null) return 0;

    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      
      // If parsing fails, throw descriptive error
      throw ParseException(
        message: 'Cannot parse "$value" as int for field $fieldName',
      );
    }

    throw ParseException(
      message: 'Invalid type for $fieldName: expected int/double/String but got ${value.runtimeType}',
    );
  }

  Map<String, dynamic> toJson() => {
    'profile_id': profileId,
    'avatar_url': avatarUrl,
    'rank_name': rankName,
    'learning_streak': learningStreak,
    'learning_count': learningCount,
    'location': location,
    'bio': bio,
    'phone_number': phoneNumber,
    'level': level,
    'xp': xp,
    'hour_learned': hourLearned,
    'user_id': userId,
  };

  Profile copyWith({
    String? profileId,
    String? avatarUrl,
    String? rankName,
    int? learningStreak,
    int? learningCount,
    String? location,
    String? bio,
    int? level,
    int? xp,
    int? hourLearned,
    String? userId,
  }) {
    return Profile(
      profileId: profileId ?? this.profileId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rankName: rankName ?? this.rankName,
      learningStreak: learningStreak ?? this.learningStreak,
      learningCount: learningCount ?? this.learningCount,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      hourLearned: hourLearned ?? this.hourLearned,
      userId: userId ?? this.userId,
    );
  }
}
