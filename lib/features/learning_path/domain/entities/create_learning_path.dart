class CreateLearningPath {
  final String title;
  final String objective;
  final String description;
  final String creatorId;
  final String? coverImgUrl;
  final String publishStatus;

  const CreateLearningPath({
    required this.title,
    required this.objective,
    required this.description,
    required this.creatorId,
    this.coverImgUrl,
    this.publishStatus = 'draft',
  });
}
