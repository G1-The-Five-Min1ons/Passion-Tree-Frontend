import 'package:passion_tree_frontend/features/learning_path/domain/entities/comment.dart';

abstract class CommentRepository {
  Future<List<Comment>> getNodeComments(String nodeId);
  Future<List<Comment>> getPathComments(String pathId);
  Future<Comment> createComment(
    String nodeId,
    String message, {
    String? parentId,
  });
  Future<Comment> createPathComment(
    String pathId,
    String message, {
    String? parentId,
  });
  Future<Comment> updateComment(String commentId, String message);
  Future<void> deleteComment(String commentId);
  Future<void> addReaction(String commentId, String reactionType);
}
