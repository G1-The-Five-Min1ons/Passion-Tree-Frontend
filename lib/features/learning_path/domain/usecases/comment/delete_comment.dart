import 'package:passion_tree_frontend/features/learning_path/domain/repositories/comment_repository.dart';

class DeleteComment {
  final CommentRepository repository;

  DeleteComment(this.repository);

  Future<void> call(String commentId) async {
    return await repository.deleteComment(commentId);
  }
}
