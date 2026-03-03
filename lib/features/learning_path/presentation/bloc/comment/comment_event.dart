import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class FetchNodeComments extends CommentEvent {
  final String nodeId;

  const FetchNodeComments(this.nodeId);

  @override
  List<Object> get props => [nodeId];
}

class AddComment extends CommentEvent {
  final String nodeId;
  final String message;
  final String? parentId;

  const AddComment({
    required this.nodeId,
    required this.message,
    this.parentId,
  });

  @override
  List<Object?> get props => [nodeId, message, parentId];
}

class EditComment extends CommentEvent {
  final String commentId;
  final String message;
  final String nodeId;

  const EditComment({
    required this.commentId,
    required this.message,
    required this.nodeId,
  });

  @override
  List<Object> get props => [commentId, message, nodeId];
}

class RemoveComment extends CommentEvent {
  final String commentId;
  final String nodeId;

  const RemoveComment({required this.commentId, required this.nodeId});

  @override
  List<Object> get props => [commentId, nodeId];
}

class AddReaction extends CommentEvent {
  final String commentId;
  final String reactionType;
  final String nodeId;

  const AddReaction({
    required this.commentId,
    required this.reactionType,
    required this.nodeId,
  });

  @override
  List<Object> get props => [commentId, reactionType, nodeId];
}
