class Comment {
  final String userId;
  final String userName;
  final String commentId;
  final String message;
  final DateTime createdAt;
  final DateTime? editAt;
  final String? nodeId;
  final String? pathId;
  final String? parentId;
  final List<CommentReaction> reactions;
  final List<CommentMention> mentions;

  const Comment({
    required this.userId,
    this.userName = 'Unknown User',
    required this.commentId,
    required this.message,
    required this.createdAt,
    this.editAt,
    this.nodeId,
    this.pathId,
    this.parentId,
    this.reactions = const [],
    this.mentions = const [],
  });
}

class CommentReaction {
  final String reactionId;
  final String reactionType;
  final String commentId;
  final String? userId;

  const CommentReaction({
    required this.reactionId,
    required this.reactionType,
    required this.commentId,
    this.userId,
  });
}

class CommentMention {
  final String mentionId;
  final DateTime createdAt;
  final String commentId;
  final String mentionedUserId;

  const CommentMention({
    required this.mentionId,
    required this.createdAt,
    required this.commentId,
    required this.mentionedUserId,
  });
}
