import 'package:passion_tree_frontend/features/learning_path/domain/entities/comment.dart';

class CommentApiModel extends Comment {
  CommentApiModel({
    required super.userId,
    required super.userName,
    required super.commentId,
    required super.message,
    required super.createdAt,
    super.editAt,
    super.nodeId,
    super.pathId,
    super.parentId,
    super.reactions = const [],
    super.mentions = const [],
  });

  factory CommentApiModel.fromJson(Map<String, dynamic> json) {
    return CommentApiModel(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? 'Unknown User',
      commentId: json['comment_id'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['create_at'] != null
          ? DateTime.parse(json['create_at'])
          : DateTime.now(),
      editAt: json['edit_at'] != null ? DateTime.parse(json['edit_at']) : null,
      nodeId: json['node_id'],
      pathId: json['path_id'],
      parentId: json['parent_id'],
      reactions:
          (json['reactions'] as List<dynamic>?)
              ?.map(
                (e) =>
                    CommentReactionApiModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      mentions:
          (json['mentions'] as List<dynamic>?)
              ?.map(
                (e) =>
                    CommentMentionApiModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class CommentReactionApiModel extends CommentReaction {
  CommentReactionApiModel({
    required super.reactionId,
    required super.reactionType,
    required super.commentId,
    super.userId,
  });

  factory CommentReactionApiModel.fromJson(Map<String, dynamic> json) {
    return CommentReactionApiModel(
      reactionId: json['reaction_id'] ?? '',
      reactionType: json['reaction_type'] ?? '',
      commentId: json['comment_id'] ?? '',
      userId: json['user_id'],
    );
  }
}

class CommentMentionApiModel extends CommentMention {
  CommentMentionApiModel({
    required super.mentionId,
    required super.createdAt,
    required super.commentId,
    required super.mentionedUserId,
  });

  factory CommentMentionApiModel.fromJson(Map<String, dynamic> json) {
    return CommentMentionApiModel(
      mentionId: json['mention_id'] ?? '',
      createdAt: json['create_at'] != null
          ? DateTime.parse(json['create_at'])
          : DateTime.now(),
      commentId: json['comment_id'] ?? '',
      mentionedUserId: json['mentioned_user_id'] ?? '',
    );
  }
}
