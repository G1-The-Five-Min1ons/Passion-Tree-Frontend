import 'package:equatable/equatable.dart';

class Profile extends Equatable {
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

  const Profile({
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

  @override
  List<Object?> get props => [
        profileId,
        avatarUrl,
        rankName,
        learningStreak,
        learningCount,
        location,
        bio,
        level,
        xp,
        hourLearned,
        userId,
      ];

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
