import 'package:passion_tree_frontend/features/learning_path/domain/entities/comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/comment_repository.dart';

class GetNodeComments {
  final CommentRepository repository;

  GetNodeComments(this.repository);

  Future<List<Comment>> call(String nodeId) async {
    return await repository.getNodeComments(nodeId);
  }
}
