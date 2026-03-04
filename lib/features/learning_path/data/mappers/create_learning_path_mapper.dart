import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_path_request_api_model.dart';

extension CreateLearningPathMapper on CreateLearningPath {
  CreatePathRequestApiModel toApiModel() {
    return CreatePathRequestApiModel(
      title: title,
      objective: objective,
      description: description,
      creatorId: creatorId,
      coverImgUrl: coverImgUrl,
      publishStatus: publishStatus,
    );
  }
}

extension CreatePathRequestApiModelMapper on CreatePathRequestApiModel {
  CreateLearningPath toEntity() {
    return CreateLearningPath(
      title: title,
      objective: objective,
      description: description,
      creatorId: creatorId,
      coverImgUrl: coverImgUrl,
      publishStatus: publishStatus,
    );
  }
}
