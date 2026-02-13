class LearningPathProgressApiModel {
  final String pathId;
  final int totalNodes;
  final int completedNodes;
  final double progressPercentage;
  final String status;

  LearningPathProgressApiModel({
    required this.pathId,
    required this.totalNodes,
    required this.completedNodes,
    required this.progressPercentage,
    required this.status,
  });

  factory LearningPathProgressApiModel.fromJson(Map<String, dynamic> json) {
    return LearningPathProgressApiModel(
      pathId: json['path_id'],
      totalNodes: json['total_nodes'],
      completedNodes: json['completed_nodes'],
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
      status: json['status'],
    );
  }
}
