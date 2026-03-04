import 'package:passion_tree_frontend/features/learning_path/domain/entities/comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/comment_repository.dart';

class CreatePathComment {
  final CommentRepository repository;

  CreatePathComment(this.repository);

  Future<Comment> call(
    String pathId,
    String message, {
    String? parentId,
  }) async {
    return await repository.createPathComment(
      pathId,
      message,
      parentId: parentId,
    );
  }
}
