class LearningPathRating {
  final String ratingId;
  final int ratingContent;
  final int ratingInstruct;
  final double ratingOverall;
  final String userId;
  final String pathId;

  const LearningPathRating({
    required this.ratingId,
    required this.ratingContent,
    required this.ratingInstruct,
    required this.ratingOverall,
    required this.userId,
    required this.pathId,
  });
}
