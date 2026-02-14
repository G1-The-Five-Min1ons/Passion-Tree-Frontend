class EnrolledLearningPath {
  final String pathId;
  final String title;
  final String description;
  final String instructor;
  final double rating;
  final String coverImgUrl;
  final int modules;
  final int completedNodes;
  final double progressPercent;
  final String progressStatus;

  const EnrolledLearningPath({
    required this.pathId,
    required this.title,
    required this.description,
    required this.instructor,
    required this.rating,
    required this.coverImgUrl,
    required this.modules,
    required this.completedNodes,
    required this.progressPercent,
    required this.progressStatus,
  });
}
