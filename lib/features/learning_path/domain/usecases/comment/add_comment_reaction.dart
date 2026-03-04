import 'package:passion_tree_frontend/features/learning_path/domain/repositories/comment_repository.dart';

class AddCommentReaction {
  final CommentRepository repository;

  AddCommentReaction(this.repository);

  Future<void> call(String commentId, String reactionType) {
    return repository.addReaction(commentId, reactionType);
  }
}
