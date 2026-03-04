import 'package:passion_tree_frontend/features/learning_path/data/datasources/comment_remote_data_source.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;

  CommentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Comment>> getNodeComments(String nodeId) async {
    return await remoteDataSource.getNodeComments(nodeId);
  }

  @override
  Future<List<Comment>> getPathComments(String pathId) async {
    return await remoteDataSource.getPathComments(pathId);
  }

  @override
  Future<Comment> createComment(
    String nodeId,
    String message, {
    String? parentId,
  }) async {
    return await remoteDataSource.createComment(
      nodeId,
      message,
      parentId: parentId,
    );
  }

  @override
  Future<Comment> createPathComment(
    String pathId,
    String message, {
    String? parentId,
  }) async {
    return await remoteDataSource.createPathComment(
      pathId,
      message,
      parentId: parentId,
    );
  }

  @override
  Future<Comment> updateComment(String commentId, String message) async {
    return await remoteDataSource.updateComment(commentId, message);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await remoteDataSource.deleteComment(commentId);
  }

  @override
  Future<void> addReaction(String commentId, String reactionType) async {
    await remoteDataSource.addReaction(commentId, reactionType);
  }
}
