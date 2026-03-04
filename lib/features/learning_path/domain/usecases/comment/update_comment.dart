import 'package:passion_tree_frontend/features/learning_path/domain/entities/comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/comment_repository.dart';

class UpdateComment {
  final CommentRepository repository;

  UpdateComment(this.repository);

  Future<Comment> call(String commentId, String message) async {
    return await repository.updateComment(commentId, message);
  }
}
