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

class CommentsSection extends StatelessWidget {
  final String? nodeId;
  final String? pathId;

  const CommentsSection({super.key, this.nodeId, this.pathId})
    : assert(nodeId != null || pathId != null);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<CommentBloc>()
            ..add(FetchComments(nodeId: nodeId, pathId: pathId)),
      child: _CommentsSectionContent(nodeId: nodeId, pathId: pathId),
    );
  }
}

class _CommentsSectionContent extends StatefulWidget {
  final String? nodeId;
  final String? pathId;

  const _CommentsSectionContent({this.nodeId, this.pathId});

  @override
  State<_CommentsSectionContent> createState() =>
      _CommentsSectionContentState();
}

class _CommentsSectionContentState extends State<_CommentsSectionContent> {
  final TextEditingController _commentController = TextEditingController();
  late final FocusNode _focusNode;
  String? _replyingToCommentId;
  String? _replyingToUsername;

  bool _isMentioning = false;
  String _mentionSearchQuery = '';
  int _mentionStartIndex = -1;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _commentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _commentController.text;
    final selection = _commentController.selection;

    if (selection.baseOffset == -1) return;

    int lastAtSignIndex = text.lastIndexOf('@', selection.baseOffset - 1);

    if (lastAtSignIndex != -1) {
      if (lastAtSignIndex == 0 ||
          text[lastAtSignIndex - 1] == ' ' ||
          text[lastAtSignIndex - 1] == '\n') {
        final query = text.substring(lastAtSignIndex + 1, selection.baseOffset);
        if (query.split(' ').length <= 2) {
          setState(() {
            _isMentioning = true;
            _mentionSearchQuery = query.toLowerCase();
            _mentionStartIndex = lastAtSignIndex;
          });
          return;
        }
      }
    }

    if (_isMentioning) {
      setState(() {
        _isMentioning = false;
      });
    }
  }

  void _insertMention(String username) {
    if (_mentionStartIndex == -1) return;
    final text = _commentController.text;
    final selection = _commentController.selection;

    final replacedText = text.replaceRange(
      _mentionStartIndex,
      selection.baseOffset,
      '@$username ',
    );

    _commentController.value = TextEditingValue(
      text: replacedText,
      selection: TextSelection.collapsed(
        offset: _mentionStartIndex + username.length + 2,
      ),
    );

    setState(() {
      _isMentioning = false;
    });
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      context.read<CommentBloc>().add(
        AddComment(
          nodeId: widget.nodeId,
          pathId: widget.pathId,
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

    // Suggest the mention to the user
    final mentionText = '@$username ';
    _commentController.value = TextEditingValue(
      text: mentionText,
      selection: TextSelection.collapsed(offset: mentionText.length),
    );

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
      RemoveComment(
        commentId: commentId,
        nodeId: widget.nodeId,
        pathId: widget.pathId,
      ),
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

          // Get unique users for mentioning
          Builder(
            builder: (context) {
              final state = context.read<CommentBloc>().state;
              List<String> uniqueUserNames = [];
              if (state is CommentLoaded) {
                uniqueUserNames = state.comments
                    .map((c) => c.userName)
                    .toSet()
                    .toList();
              }

              final filteredUsers = uniqueUserNames
                  .where(
                    (name) => name.toLowerCase().contains(_mentionSearchQuery),
                  )
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isMentioning && filteredUsers.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final username = filteredUsers[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.person, size: 20),
                            title: Text(username),
                            onTap: () => _insertMention(username),
                          );
                        },
                      ),
                    ),
                  if (_replyingToUsername != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Text(
                            'Replying to $_replyingToUsername',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _cancelReply,
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
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
                      pathId: widget.pathId,
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

class _CommentItem extends StatefulWidget {
  final Comment comment;
  final List<Comment> replies;
  final String? nodeId;
  final String? pathId;
  final VoidCallback onDelete;
  final VoidCallback onReply;
  final String currentUserId;
  final bool isNested;

  const _CommentItem({
    required this.comment,
    required this.replies,
    this.nodeId,
    this.pathId,
    required this.onDelete,
    required this.onReply,
    required this.currentUserId,
    this.isNested = false,
  });

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  bool _showReplies = false;

  List<TextSpan> _buildMessageSpans(String message, Color primaryColor) {
    // Basic parser for matching "@Username" or "@User Name" up to 2 words max.
    final spans = <TextSpan>[];
    int start = 0;
    final regex = RegExp(r'@[\p{L}\p{N}_]+(?: [\p{L}\p{N}_]+)?', unicode: true);
    final matches = regex.allMatches(message);

    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: message.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
      );
      start = match.end;
    }

    if (start < message.length) {
      spans.add(TextSpan(text: message.substring(start)));
    }

    return spans;
  }

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
    final isOwner = widget.comment.userId == widget.currentUserId;
    final isLiked = widget.comment.reactions.any(
      (r) => r.userId == widget.currentUserId && r.reactionType == 'like',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: widget.isNested ? 16 : 20,
                backgroundColor: colors.primary.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  color: colors.primary,
                  size: widget.isNested ? 16 : 24,
                ),
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
                            widget.comment.userName,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimeAgo(widget.comment.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colors.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: _buildMessageSpans(
                          widget.comment.message,
                          colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: isLiked ? Colors.red : null,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            context.read<CommentBloc>().add(
                              AddReaction(
                                commentId: widget.comment.commentId,
                                reactionType: 'like',
                                nodeId: widget.nodeId,
                                pathId: widget.pathId,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.comment.reactions.length}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: widget.onReply,
                          child: Text(
                            'Reply',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (widget.replies.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showReplies = !_showReplies;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 1,
                                color: colors.onSurface.withOpacity(0.3),
                                margin: const EdgeInsets.only(right: 8),
                              ),
                              Text(
                                _showReplies
                                    ? 'Hide replies'
                                    : 'View ${widget.replies.length} ${widget.replies.length == 1 ? "reply" : "replies"}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                              ),
                              Icon(
                                _showReplies
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 16,
                                color: colors.primary,
                              ),
                            ],
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
                              widget.onDelete();
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

          // Replies Section
          if (_showReplies && widget.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 48.0, top: 4.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.replies.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final reply = widget.replies[index];
                  return _CommentItem(
                    comment: reply,
                    replies:
                        const [], // Nested replies generally not supported or limited to 1 level here
                    nodeId: widget.nodeId,
                    currentUserId: widget.currentUserId,
                    isNested: true,
                    onDelete: () {
                      context.read<CommentBloc>().add(
                        RemoveComment(
                          commentId: reply.commentId,
                          nodeId: widget.nodeId,
                          pathId: widget.pathId,
                        ),
                      );
                    },
                    onReply: widget
                        .onReply, // A reply to a reply usually tags the user and goes back to root
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
