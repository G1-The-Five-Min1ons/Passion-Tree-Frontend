class LearningPathProgress {
  final String pathId;
  final int totalNodes;
  final int completedNodes;
  final double progressPercentage;
  final String status;

  const LearningPathProgress({
    required this.pathId,
    required this.totalNodes,
    required this.completedNodes,
    required this.progressPercentage,
    required this.status,
  });
}
