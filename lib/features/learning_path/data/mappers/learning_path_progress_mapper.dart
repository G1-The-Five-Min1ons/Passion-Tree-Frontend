import '../../domain/entities/learning_path_progress.dart';
import '../models/learning_path_progress_api_model.dart';

extension LearningPathProgressMapper on LearningPathProgressApiModel {
  LearningPathProgress toEntity() {
    return LearningPathProgress(
      pathId: pathId,
      totalNodes: totalNodes,
      completedNodes: completedNodes,
      progressPercentage: progressPercentage,
      status: status,
    );
  }
}
