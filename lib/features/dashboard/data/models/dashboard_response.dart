/// Dashboard API response model matching backend DashboardResponse
class DashboardResponse {
  final DashboardUserInfo userInfo;
  final List<MissionItem> weeklyMissions;
  final List<CurrentPathItem> currentPaths;
  final TreeCounterStats treeCounter;
  final List<ActivityItem> recentActivity;
  final List<ActivityHeatmapItem> activitySummary;

  DashboardResponse({
    required this.userInfo,
    required this.weeklyMissions,
    required this.currentPaths,
    required this.treeCounter,
    required this.recentActivity,
    required this.activitySummary,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      userInfo: DashboardUserInfo.fromJson(
        json['user_information'] as Map<String, dynamic>? ?? {},
      ),
      weeklyMissions: (json['weekly_missions'] as List<dynamic>?)
              ?.map((e) => MissionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentPaths: (json['current_paths'] as List<dynamic>?)
              ?.map(
                (e) => CurrentPathItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      treeCounter: TreeCounterStats.fromJson(
        json['tree_counter'] as Map<String, dynamic>? ?? {},
      ),
      recentActivity: (json['recent_activity'] as List<dynamic>?)
              ?.map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activitySummary: (json['activity_summary'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ActivityHeatmapItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class DashboardUserInfo {
  final String username;
  final String firstName;
  final String avatarUrl;
  final int level;
  final int xp;
  final String rankName;
  final int learningStreak;
  final int hourLearned;

  DashboardUserInfo({
    required this.username,
    required this.firstName,
    required this.avatarUrl,
    required this.level,
    required this.xp,
    required this.rankName,
    required this.learningStreak,
    required this.hourLearned,
  });

  factory DashboardUserInfo.fromJson(Map<String, dynamic> json) {
    return DashboardUserInfo(
      username: json['username'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      level: json['level'] as int? ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      rankName: json['rank_name'] as String? ?? 'Beginner',
      learningStreak: json['learning_streak'] as int? ?? 0,
      hourLearned: json['hour_learned'] as int? ?? 0,
    );
  }
}

class MissionItem {
  final String missionId;
  final String detail;
  final int rewardXp;
  final String status;
  final DateTime? expireAt;

  MissionItem({
    required this.missionId,
    required this.detail,
    required this.rewardXp,
    required this.status,
    this.expireAt,
  });

  factory MissionItem.fromJson(Map<String, dynamic> json) {
    return MissionItem(
      missionId: json['mission_id'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      rewardXp: (json['reward_xp'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      expireAt: json['expire_at'] != null
          ? DateTime.tryParse(json['expire_at'] as String)
          : null,
    );
  }

  bool get isCompleted => status == 'completed';
}

class CurrentPathItem {
  final String pathId;
  final String title;
  final String coverImgUrl;
  final double progressPercent;
  final String instructor;
  final String description;
  final int completedModules;
  final int totalModules;

  CurrentPathItem({
    required this.pathId,
    required this.title,
    required this.coverImgUrl,
    required this.progressPercent,
    this.instructor = '',
    this.description = '',
    this.completedModules = 0,
    this.totalModules = 0,
  });

  factory CurrentPathItem.fromJson(Map<String, dynamic> json) {
    return CurrentPathItem(
      pathId: json['path_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      coverImgUrl: json['cover_img_url'] as String? ?? '',
      progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0.0,
      instructor: json['instructor'] as String? ?? '',
      description: json['description'] as String? ?? '',
      completedModules: (json['completed_modules'] as num?)?.toInt() ?? 0,
      totalModules: (json['total_modules'] as num?)?.toInt() ?? 0,
    );
  }
}

class TreeCounterStats {
  final int totalTreesPlanted;
  final int totalNodesUnlocked;

  TreeCounterStats({
    required this.totalTreesPlanted,
    required this.totalNodesUnlocked,
  });

  factory TreeCounterStats.fromJson(Map<String, dynamic> json) {
    return TreeCounterStats(
      totalTreesPlanted: json['total_trees_planted'] as int? ?? 0,
      totalNodesUnlocked: json['total_nodes_unlocked'] as int? ?? 0,
    );
  }
}

class ActivityItem {
  final String activityType;
  final String title;
  final DateTime timestamp;

  ActivityItem({
    required this.activityType,
    required this.title,
    required this.timestamp,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      activityType: json['activity_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Human-readable label for the activity type
  String get typeLabel {
    switch (activityType) {
      case 'enroll_path':
        return 'Learning';
      case 'complete_node':
        return 'Completed';
      case 'complete_mission':
        return 'Mission';
      default:
        return 'Activity';
    }
  }

  /// Human-readable relative time string
  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${(diff.inDays / 7).floor()} weeks ago';
  }
}

class ActivityHeatmapItem {
  final String date;
  final int count;

  ActivityHeatmapItem({
    required this.date,
    required this.count,
  });

  factory ActivityHeatmapItem.fromJson(Map<String, dynamic> json) {
    return ActivityHeatmapItem(
      date: json['date'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}
