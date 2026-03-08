class LearningPath {
  final String id;
  final String title;
  final String description;
  final String objective;
  final String coverImageUrl;
  final double rating;
  final String publishStatus;
  final String instructor;
  final int students;
  final int modules;

  const LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.objective,
    required this.coverImageUrl,
    required this.rating,
    required this.publishStatus,
    required this.instructor,
    required this.students,
    required this.modules,
  });
}
