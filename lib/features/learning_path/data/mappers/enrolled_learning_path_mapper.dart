import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/enrolled_learning_path_api_model.dart';

extension EnrolledLearningPathMapper on EnrolledLearningPathApiModel {
  EnrolledLearningPath toEntity() {
    return EnrolledLearningPath(
      pathId: pathId,
      title: title,
      description: description,
      instructor: instructor,
      rating: rating,
      coverImgUrl: coverImgUrl,
      modules: modules,
      completedNodes: completedNodes,
      progressPercent: progressPercent,
      progressStatus: progressStatus,
    );
  }
}
