import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class FetchComments extends CommentEvent {
  final String? nodeId;
  final String? pathId;

  const FetchComments({this.nodeId, this.pathId})
    : assert(nodeId != null || pathId != null);

  @override
  List<Object?> get props => [nodeId, pathId];
}

class AddComment extends CommentEvent {
  final String? nodeId;
  final String? pathId;
  final String message;
  final String? parentId;

  const AddComment({
    this.nodeId,
    this.pathId,
    required this.message,
    this.parentId,
  }) : assert(nodeId != null || pathId != null);

  @override
  List<Object?> get props => [nodeId, pathId, message, parentId];
}

class EditComment extends CommentEvent {
  final String commentId;
  final String message;
  final String? nodeId;
  final String? pathId;

  const EditComment({
    required this.commentId,
    required this.message,
    this.nodeId,
    this.pathId,
  });

  @override
  List<Object?> get props => [commentId, message, nodeId, pathId];
}

class RemoveComment extends CommentEvent {
  final String commentId;
  final String? nodeId;
  final String? pathId;

  const RemoveComment({required this.commentId, this.nodeId, this.pathId});

  @override
  List<Object?> get props => [commentId, nodeId, pathId];
}

class AddReaction extends CommentEvent {
  final String commentId;
  final String reactionType;
  final String? nodeId;
  final String? pathId;

  const AddReaction({
    required this.commentId,
    required this.reactionType,
    this.nodeId,
    this.pathId,
  });

  @override
  List<Object?> get props => [commentId, reactionType, nodeId, pathId];
}
