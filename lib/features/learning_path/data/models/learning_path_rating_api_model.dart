class LearningPathRatingApiModel {
  final String ratingId;
  final int ratingContent;
  final int ratingInstruct;
  final double ratingOverall;
  final String userId;
  final String pathId;

  const LearningPathRatingApiModel({
    required this.ratingId,
    required this.ratingContent,
    required this.ratingInstruct,
    required this.ratingOverall,
    required this.userId,
    required this.pathId,
  });

  factory LearningPathRatingApiModel.fromJson(Map<String, dynamic> json) {
    return LearningPathRatingApiModel(
      ratingId: json['rating_id']?.toString() ?? '',
      ratingContent: (json['rating_content'] as num?)?.toInt() ?? 0,
      ratingInstruct: (json['rating_instruct'] as num?)?.toInt() ?? 0,
      ratingOverall: (json['rating_overall'] as num?)?.toDouble() ?? 0,
      userId: json['user_id']?.toString() ?? '',
      pathId: json['path_id']?.toString() ?? '',
    );
  }
}
