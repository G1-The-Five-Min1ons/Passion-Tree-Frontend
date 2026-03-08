import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_path_api_model.dart';

extension LearningPathMapper on LearningPathApiModel {
  LearningPath toEntity() {
    return LearningPath(
      id: id,
      title: title,
      description: description,
      objective: objective,
      coverImageUrl: coverImgUrl,
      rating: rating,
      publishStatus: publishStatus,
      instructor: instructor,
      students: students,
      modules: modules,
    );
  }

}
