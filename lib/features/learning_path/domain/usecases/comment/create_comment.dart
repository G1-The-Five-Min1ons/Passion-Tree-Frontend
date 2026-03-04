import 'package:passion_tree_frontend/features/learning_path/domain/entities/comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/comment_repository.dart';

class CreateComment {
  final CommentRepository repository;

  CreateComment(this.repository);

  Future<Comment> call(
    String nodeId,
    String message, {
    String? parentId,
  }) async {
    return await repository.createComment(nodeId, message, parentId: parentId);
  }
}
