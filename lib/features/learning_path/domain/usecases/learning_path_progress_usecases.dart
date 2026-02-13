class GetLearningPathProgress {
  final LearningPathRepository repository;

  GetLearningPathProgress(this.repository);

  Future<LearningPathProgress> call(String pathId, String userId) {
    return repository.getLearningPathProgress(pathId, userId);
  }
}
