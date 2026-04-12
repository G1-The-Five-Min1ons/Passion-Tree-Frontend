import 'package:passion_tree_frontend/features/learning_path/data/models/learning_path_rating_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path_rating.dart';

extension LearningPathRatingMapper on LearningPathRatingApiModel {
  LearningPathRating toEntity() {
    return LearningPathRating(
      ratingId: ratingId,
      ratingContent: ratingContent,
      ratingInstruct: ratingInstruct,
      ratingOverall: ratingOverall,
      userId: userId,
      pathId: pathId,
    );
  }
}
