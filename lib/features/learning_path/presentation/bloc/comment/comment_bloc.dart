import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/get_node_comments.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/create_comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/update_comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/delete_comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/add_comment_reaction.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/comment/comment_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/comment/comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetNodeComments getNodeComments;
  final CreateComment createComment;
  final UpdateComment updateComment;
  final DeleteComment deleteComment;
  final AddCommentReaction addCommentReaction;

  CommentBloc({
    required this.getNodeComments,
    required this.createComment,
    required this.updateComment,
    required this.deleteComment,
    required this.addCommentReaction,
  }) : super(CommentInitial()) {
    on<FetchNodeComments>(_onFetchNodeComments);
    on<AddComment>(_onAddComment);
    on<EditComment>(_onEditComment);
    on<RemoveComment>(_onRemoveComment);
    on<AddReaction>(_onAddReaction);
  }

  Future<void> _onFetchNodeComments(
    FetchNodeComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    try {
      final comments = await getNodeComments(event.nodeId);
      emit(CommentLoaded(comments));
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onAddComment(
    AddComment event,
    Emitter<CommentState> emit,
  ) async {
    try {
      await createComment(
        event.nodeId,
        event.message,
        parentId: event.parentId,
      );
      add(FetchNodeComments(event.nodeId));
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onEditComment(
    EditComment event,
    Emitter<CommentState> emit,
  ) async {
    try {
      await updateComment(event.commentId, event.message);
      add(FetchNodeComments(event.nodeId));
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onRemoveComment(
    RemoveComment event,
    Emitter<CommentState> emit,
  ) async {
    try {
      await deleteComment(event.commentId);
      add(FetchNodeComments(event.nodeId));
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onAddReaction(
    AddReaction event,
    Emitter<CommentState> emit,
  ) async {
    try {
      await addCommentReaction(event.commentId, event.reactionType);
      add(FetchNodeComments(event.nodeId));
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }
}
