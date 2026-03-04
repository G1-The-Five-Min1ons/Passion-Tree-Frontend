import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/get_node_comments.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/get_path_comments.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/create_comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/create_path_comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/update_comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/delete_comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/add_comment_reaction.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/comment/comment_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/comment/comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetNodeComments getNodeComments;
  final GetPathComments getPathComments;
  final CreateComment createComment;
  final CreatePathComment createPathComment;
  final UpdateComment updateComment;
  final DeleteComment deleteComment;
  final AddCommentReaction addCommentReaction;

  CommentBloc({
    required this.getNodeComments,
    required this.getPathComments,
    required this.createComment,
    required this.createPathComment,
    required this.updateComment,
    required this.deleteComment,
    required this.addCommentReaction,
  }) : super(CommentInitial()) {
    on<FetchComments>(_onFetchComments);
    on<AddComment>(_onAddComment);
    on<EditComment>(_onEditComment);
    on<RemoveComment>(_onRemoveComment);
    on<AddReaction>(_onAddReaction);
  }

  void _dispatchFetchRefresh(String? nodeId, String? pathId) {
    if (nodeId != null) {
      add(FetchComments(nodeId: nodeId));
    } else if (pathId != null) {
      add(FetchComments(pathId: pathId));
    }
  }

  Future<void> _onFetchComments(
    FetchComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    try {
      List<Comment> comments = [];
      if (event.nodeId != null) {
        comments = await getNodeComments(event.nodeId!);
      } else if (event.pathId != null) {
        comments = await getPathComments(event.pathId!);
      }
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
      if (event.nodeId != null) {
        await createComment(
          event.nodeId!,
          event.message,
          parentId: event.parentId,
        );
      } else if (event.pathId != null) {
        await createPathComment(
          event.pathId!,
          event.message,
          parentId: event.parentId,
        );
      }
      _dispatchFetchRefresh(event.nodeId, event.pathId);
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
      _dispatchFetchRefresh(event.nodeId, event.pathId);
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
      _dispatchFetchRefresh(event.nodeId, event.pathId);
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
      _dispatchFetchRefresh(event.nodeId, event.pathId);
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }
}
