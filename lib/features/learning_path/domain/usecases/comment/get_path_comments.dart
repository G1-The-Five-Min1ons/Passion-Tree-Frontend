import 'package:passion_tree_frontend/features/learning_path/domain/entities/comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/comment_repository.dart';

class GetPathComments {
  final CommentRepository repository;

  GetPathComments(this.repository);

  Future<List<Comment>> call(String pathId) async {
    return await repository.getPathComments(pathId);
  }
}
