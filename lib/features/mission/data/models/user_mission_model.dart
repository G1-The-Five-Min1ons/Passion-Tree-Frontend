/// User mission model matching backend `UserMission`
/// (passiontree/internal/mission/model/mission_model.go)
class UserMissionModel {
  final String userMissionId;
  final String userId;
  final String missionId;
  final String title;
  final String description;
  final int rewardXp;
  final int rewardHeart;
  final int currentValue;
  final int targetValue;
  final String status;
  final DateTime? expireAt;
  final DateTime? completeAt;

  const UserMissionModel({
    required this.userMissionId,
    required this.userId,
    required this.missionId,
    required this.title,
    required this.description,
    required this.rewardXp,
    required this.rewardHeart,
    required this.currentValue,
    required this.targetValue,
    required this.status,
    this.expireAt,
    this.completeAt,
  });

  factory UserMissionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      final str = raw.toString();
      if (str.isEmpty) return null;
      return DateTime.tryParse(str);
    }

    return UserMissionModel(
      userMissionId: json['user_mission_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      missionId: json['mission_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rewardXp: (json['reward_xp'] as num?)?.toInt() ?? 0,
      rewardHeart: (json['reward_heart'] as num?)?.toInt() ?? 0,
      currentValue: (json['current_value'] as num?)?.toInt() ?? 0,
      targetValue: (json['target_value'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      expireAt: parseDate(json['expire_at']),
      completeAt: parseDate(json['complete_at']),
    );
  }

  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Progress in [0.0, 1.0] for UI bars
  double get progress {
    if (targetValue <= 0) return isCompleted ? 1.0 : 0.0;
    final ratio = currentValue / targetValue;
    if (ratio.isNaN || ratio.isInfinite) return 0.0;
    return ratio.clamp(0.0, 1.0);
  }

  /// Display text — falls back to title if description is empty
  String get detail {
    if (description.trim().isNotEmpty) return description;
    return title;
  }
}
