class EnrolledLearningPathApiModel {
  final String pathId;
  final String title;
  final String description;
  final String instructor;
  final double rating;
  final String coverImgUrl;
  final String enrollmentStatus;
  final int modules;
  final int completedNodes;
  final double progressPercent;
  final String progressStatus;

  EnrolledLearningPathApiModel({
    required this.pathId,
    required this.title,
    required this.description,
    required this.instructor,
    required this.rating,
    required this.coverImgUrl,
    required this.enrollmentStatus,
    required this.modules,
    required this.completedNodes,
    required this.progressPercent,
    required this.progressStatus,
  });

  factory EnrolledLearningPathApiModel.fromJson(Map<String, dynamic> json) {
    return EnrolledLearningPathApiModel(
      pathId: json['path_id'],
      title: json['title'],
      description: json['description'],
      instructor: json['instructor'],
      rating: (json['rating'] as num).toDouble(),
      coverImgUrl: json['cover_img_url'],
      enrollmentStatus: json['enrollment_status'],
      modules: json['modules'],
      completedNodes: json['completed_nodes'],
      progressPercent: (json['progress_percent'] as num).toDouble(),
      progressStatus: json['progress_status'],
    );
  }
}
