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
}
