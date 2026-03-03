import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/comment.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/comment/comment_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/comment/comment_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/comment/comment_state.dart';

class NodeCommentsSection extends StatelessWidget {
  final String nodeId;

  const NodeCommentsSection({super.key, required this.nodeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CommentBloc>()..add(FetchNodeComments(nodeId)),
      child: _NodeCommentsSectionContent(nodeId: nodeId),
    );
  }
}

class _NodeCommentsSectionContent extends StatefulWidget {
  final String nodeId;

  const _NodeCommentsSectionContent({required this.nodeId});

  @override
  State<_NodeCommentsSectionContent> createState() =>
      _NodeCommentsSectionContentState();
}

class _NodeCommentsSectionContentState
    extends State<_NodeCommentsSectionContent> {
  final TextEditingController _commentController = TextEditingController();
  late final FocusNode _focusNode;
  String? _replyingToCommentId;
  String? _replyingToUsername;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      context.read<CommentBloc>().add(
        AddComment(
          nodeId: widget.nodeId,
          message: text,
          parentId: _replyingToCommentId,
        ),
      );
      _commentController.clear();
      setState(() {
        _replyingToCommentId = null;
        _replyingToUsername = null;
      });
      _focusNode.unfocus();
    }
  }

  void _startReply(String commentId, String username) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUsername = username;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
    });
    _focusNode.unfocus();
  }

  void _deleteComment(String commentId) {
    context.read<CommentBloc>().add(
      RemoveComment(commentId: commentId, nodeId: widget.nodeId),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PixelBorderContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.cardBorder,
      fillColor: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== TITLE =====
          Text('Comments', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // ===== INPUT AREA =====
          if (_replyingToUsername != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text(
                    'Replying to $_replyingToUsername',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _submitComment(),
                ),
              ),
              const SizedBox(width: 8),
              AppButton(
                variant: AppButtonVariant.text,
                onPressed: _submitComment,
                text: 'Post',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ===== COMMENTS LIST =====
          BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              if (state is CommentLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CommentError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: colors.error),
                  ),
                );
              }

              if (state is CommentLoaded) {
                final comments = state.comments;
                if (comments.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No comments yet. Be the first to comment!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments
                      .where((c) => c.parentId == null || c.parentId!.isEmpty)
                      .length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final rootComments = comments
                        .where((c) => c.parentId == null || c.parentId!.isEmpty)
                        .toList();
                    final comment = rootComments[index];
                    final replies = comments
                        .where((c) => c.parentId == comment.commentId)
                        .toList();

                    return _CommentItem(
                      comment: comment,
                      replies: replies,
                      nodeId: widget.nodeId,
                      onDelete: () => _deleteComment(comment.commentId),
                      onReply: () =>
                          _startReply(comment.commentId, comment.userName),
                      currentUserId:
                          'a33282ca-e6f1-4fbf-9f51-fab7ffba3bfc', // Hardcoded temporarily like in learning_node.dart
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Comment comment;
  final List<Comment> replies;
  final String nodeId;
  final VoidCallback onDelete;
  final VoidCallback onReply;
  final String currentUserId;

  const _CommentItem({
    required this.comment,
    required this.replies,
    required this.nodeId,
    required this.onDelete,
    required this.onReply,
    required this.currentUserId,
  });

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays >= 7) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks ${weeks == 1 ? "week" : "weeks"} ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} ${difference.inDays == 1 ? "day" : "days"} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? "hour" : "hours"} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? "minute" : "minutes"} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isOwner = comment.userId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: colors.primary.withOpacity(0.2),
            child: Icon(Icons.person, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        comment.userName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        context.read<CommentBloc>().add(
                          AddReaction(
                            commentId: comment.commentId,
                            reactionType: 'like',
                            nodeId: nodeId,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${comment.reactions.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        'Reply',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (replies.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      // Handle view replies tap
                    },
                    child: Text(
                      '${replies.length} ${replies.length == 1 ? "reply" : "replies"} >',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: colors.error,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Comment'),
                    content: const Text(
                      'Are you sure you want to delete this comment?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onDelete();
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
