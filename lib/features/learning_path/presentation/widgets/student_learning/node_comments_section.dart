import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/popups/action_popup.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_profile_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/comment.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/comment/comment_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/comment/comment_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/comment/comment_state.dart';

class CommentsSection extends StatefulWidget {
  final String? nodeId;
  final String? pathId;
  final String userId;

  const CommentsSection({
    super.key,
    this.nodeId,
    this.pathId,
    required this.userId,
  }) : assert(nodeId != null || pathId != null);

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  bool _isExpanded = false;
  bool _hasFetched = false;
  late final CommentBloc _commentBloc;

  @override
  void initState() {
    super.initState();
    _commentBloc = getIt<CommentBloc>();
  }

  @override
  void dispose() {
    _commentBloc.close();
    super.dispose();
  }

  void _handleToggle() {
    if (!_hasFetched) {
      _hasFetched = true;
      _commentBloc.add(
        FetchComments(nodeId: widget.nodeId, pathId: widget.pathId),
      );
    }
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _commentBloc,
      child: PixelBorderContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(0),
        borderColor: AppColors.cardBorder,
        fillColor: colors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TOGGLE HEADER =====
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleToggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: BlocBuilder<CommentBloc, CommentState>(
                  bloc: _commentBloc,
                  builder: (_, state) {
                    final count = state is CommentLoaded
                        ? state.comments.length
                        : 0;
                    return Row(
                      children: [
                        Text(
                          'Comments',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryBrand.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$count',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.secondaryBrand,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // ===== EXPANDED CONTENT =====
            if (_isExpanded) ...[
              Divider(
                height: 1,
                thickness: 0.5,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              _CommentsSectionContent(
                nodeId: widget.nodeId,
                pathId: widget.pathId,
                userId: widget.userId,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommentsSectionContent extends StatefulWidget {
  final String? nodeId;
  final String? pathId;
  final String userId;

  const _CommentsSectionContent({
    this.nodeId,
    this.pathId,
    required this.userId,
  });

  @override
  State<_CommentsSectionContent> createState() =>
      _CommentsSectionContentState();
}

class _CommentsSectionContentState extends State<_CommentsSectionContent> {
  final TextEditingController _commentController = TextEditingController();
  late final FocusNode _focusNode;
  List<Comment> _cachedComments = const [];
  String? _replyingToCommentId;
  String? _replyingToUsername;
  String? _editingCommentId;
  String? _editingCommentUsername;

  bool _isMentioning = false;
  String _mentionSearchQuery = '';
  int _mentionStartIndex = -1;
  String? _currentUserAvatarUrl;
  String _currentUserInitial = '?';

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _commentController.addListener(_onTextChanged);
    _loadCurrentUserProfile();
  }

  Future<void> _loadCurrentUserProfile() async {
    try {
      final result = await getIt<GetProfileUseCase>().execute();
      result.fold((_) {}, (userProfile) {
        if (!mounted) return;
        final firstName = userProfile.user.firstName;
        final username = userProfile.user.username;
        final name = firstName.isNotEmpty ? firstName : username;
        setState(() {
          _currentUserAvatarUrl = userProfile.profile?.avatarUrl;
          _currentUserInitial = name.isNotEmpty ? name[0].toUpperCase() : '?';
        });
      });
    } catch (_) {
      // ไม่แสดง error หาก load profile ไม่สำเร็จ — fallback คือตัวอักษร '?'
    }
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
      if (_editingCommentId != null) {
        context.read<CommentBloc>().add(
          EditComment(
            commentId: _editingCommentId!,
            message: text,
            nodeId: widget.nodeId,
            pathId: widget.pathId,
          ),
        );
      } else {
        context.read<CommentBloc>().add(
          AddComment(
            nodeId: widget.nodeId,
            pathId: widget.pathId,
            message: text,
            parentId: _replyingToCommentId,
          ),
        );
      }

      _commentController.clear();
      setState(() {
        _replyingToCommentId = null;
        _replyingToUsername = null;
        _editingCommentId = null;
        _editingCommentUsername = null;
      });
      _focusNode.unfocus();
    }
  }

  void _startReply(String commentId, String username) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUsername = username;
      _editingCommentId = null;
      _editingCommentUsername = null;
    });

    final mentionText = '@$username ';
    _commentController.value = TextEditingValue(
      text: mentionText,
      selection: TextSelection.collapsed(offset: mentionText.length),
    );

    _focusNode.requestFocus();
  }

  void _startEdit(String commentId, String message, String username) {
    setState(() {
      _editingCommentId = commentId;
      _editingCommentUsername = username;
      _replyingToCommentId = null;
      _replyingToUsername = null;
    });

    _commentController.value = TextEditingValue(
      text: message,
      selection: TextSelection.collapsed(offset: message.length),
    );

    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
    });
    _commentController.clear();
    _focusNode.unfocus();
  }

  void _cancelEdit() {
    setState(() {
      _editingCommentId = null;
      _editingCommentUsername = null;
    });
    _commentController.clear();
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

  String _resolveRootCommentId(
    Comment comment,
    Map<String, Comment> commentsById,
  ) {
    var current = comment;
    final visited = <String>{current.commentId};

    while (current.parentId != null && current.parentId!.isNotEmpty) {
      final parent = commentsById[current.parentId!];
      if (parent == null || !visited.add(parent.commentId)) {
        break;
      }
      current = parent;
    }

    return current.commentId;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== COMMENTS LIST =====
          BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              if (state is CommentLoaded) {
                _cachedComments = state.comments;
              }

              if (state is CommentLoading && _cachedComments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is CommentError && _cachedComments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                );
              }

              final comments = state is CommentLoaded
                  ? state.comments
                  : _cachedComments;

              final commentsById = {
                for (final comment in comments) comment.commentId: comment,
              };

              final repliesByRoot = <String, List<Comment>>{};
              for (final comment in comments) {
                final parentId = comment.parentId;
                if (parentId != null && parentId.isNotEmpty) {
                  final rootId = _resolveRootCommentId(comment, commentsById);
                  repliesByRoot.putIfAbsent(rootId, () => []).add(comment);
                }
              }

              if (comments.isEmpty) {
                return SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 40,
                          color: colors.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No comments yet',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface.withValues(alpha: 0.5),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Be the first to share your thoughts!',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.4),
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final rootComments = comments
                  .where((c) => c.parentId == null || c.parentId!.isEmpty)
                  .toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rootComments.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                itemBuilder: (context, index) {
                  final comment = rootComments[index];
                  final replies = repliesByRoot[comment.commentId] ?? const [];

                  return _CommentItem(
                    key: ValueKey(comment.commentId),
                    comment: comment,
                    replies: replies,
                    nodeId: widget.nodeId,
                    pathId: widget.pathId,
                    onDelete: () => _deleteComment(comment.commentId),
                    onEdit: _startEdit,
                    onReply: _startReply,
                    currentUserId: widget.userId,
                  );
                },
              );
            },
          ),

          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.white.withValues(alpha: 0.15),
          ),

          // ===== INPUT AREA (ด้านล่าง) =====
          _CommentInputArea(
            controller: _commentController,
            focusNode: _focusNode,
            replyingToUsername: _replyingToUsername,
            editingUsername: _editingCommentUsername,
            isMentioning: _isMentioning,
            mentionSearchQuery: _mentionSearchQuery,
            onInsertMention: _insertMention,
            onCancelReply: _cancelReply,
            onCancelEdit: _cancelEdit,
            onSubmit: _submitComment,
            avatarUrl: _currentUserAvatarUrl,
            userInitial: _currentUserInitial,
          ),
        ],
      );
  }
}

class _CommentInputArea extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? replyingToUsername;
  final String? editingUsername;
  final bool isMentioning;
  final String mentionSearchQuery;
  final void Function(String username) onInsertMention;
  final VoidCallback onCancelReply;
  final VoidCallback onCancelEdit;
  final VoidCallback onSubmit;
  final String? avatarUrl;
  final String userInitial;

  const _CommentInputArea({
    required this.controller,
    required this.focusNode,
    required this.replyingToUsername,
    required this.editingUsername,
    required this.isMentioning,
    required this.mentionSearchQuery,
    required this.onInsertMention,
    required this.onCancelReply,
    required this.onCancelEdit,
    required this.onSubmit,
    this.avatarUrl,
    this.userInitial = '?',
  });

  @override
  State<_CommentInputArea> createState() => _CommentInputAreaState();
}

class _CommentInputAreaState extends State<_CommentInputArea> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(_CommentInputArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        final uniqueUserNames = state is CommentLoaded
            ? state.comments
                  .map((c) => c.userName)
                  .where((n) => n.isNotEmpty)
                  .toSet()
                  .toList()
            : <String>[];

        final filteredUsers = uniqueUserNames
            .where(
              (name) => name.toLowerCase().contains(widget.mentionSearchQuery),
            )
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mention suggestions (popup ด้านบน input)
            if (widget.isMentioning && filteredUsers.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 160),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  border: Border(
                    bottom: BorderSide(color: AppColors.cardBorder),
                  ),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final username = filteredUsers[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primaryBrand.withValues(
                          alpha: 0.35,
                        ),
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: AppColors.secondaryBrand,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      title: Text(
                        username,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () => widget.onInsertMention(username),
                    );
                  },
                ),
              ),

            // Reply indicator banner
            if (widget.replyingToUsername != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: colors.primary.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    Icon(Icons.reply, size: 16, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Replying to ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      widget.replyingToUsername!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: widget.onCancelReply,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

            // Edit indicator banner
            if (widget.editingUsername != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: colors.secondary.withValues(alpha: 0.12),
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: colors.secondary),
                    const SizedBox(width: 6),
                    Text(
                      'Editing ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      widget.editingUsername!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.secondary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: widget.onCancelEdit,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

            // Input row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryBrand.withValues(
                      alpha: 0.35,
                    ),
                    backgroundImage:
                        (widget.avatarUrl != null &&
                            widget.avatarUrl!.isNotEmpty)
                        ? NetworkImage(widget.avatarUrl!)
                        : null,
                    child:
                        (widget.avatarUrl == null || widget.avatarUrl!.isEmpty)
                        ? Text(
                            widget.userInitial,
                            style: const TextStyle(
                              color: AppColors.secondaryBrand,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(
                            color: colors.onSurface.withValues(alpha: 0.45),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.fromLTRB(
                            12,
                            10,
                            12,
                            10,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: _hasText
                          ? colors.primary
                          : colors.onSurface.withValues(alpha: 0.35),
                    ),
                    onPressed: _hasText ? widget.onSubmit : null,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CommentItem extends StatefulWidget {
  final Comment comment;
  final List<Comment> replies;
  final String? nodeId;
  final String? pathId;
  final VoidCallback onDelete;
  final void Function(String commentId, String message, String username) onEdit;
  final void Function(String commentId, String username) onReply;
  final String currentUserId;
  final bool isNested;

  const _CommentItem({
    super.key,
    required this.comment,
    required this.replies,
    this.nodeId,
    this.pathId,
    required this.onDelete,
    required this.onEdit,
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
          style: const TextStyle(
            color: AppColors.secondaryBrand,
            fontWeight: FontWeight.bold,
          ),
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
      return '$weeks${weeks == 1 ? "w" : "w"} ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
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
    final likeCount = widget.comment.reactions
        .where((r) => r.reactionType == 'like')
        .length;

    return Padding(
      padding: EdgeInsets.fromLTRB(widget.isNested ? 0 : 16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: widget.isNested ? 14 : 18,
                backgroundColor: AppColors.primaryBrand.withValues(alpha: 0.35),
                child: Text(
                  widget.comment.userName.isNotEmpty
                      ? widget.comment.userName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: AppColors.secondaryBrand,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.isNested ? 11 : 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Comment bubble
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(
                          16,
                        ).copyWith(topLeft: const Radius.circular(4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.comment.userName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: _buildMessageSpans(
                                widget.comment.message,
                                colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action row below bubble
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Row(
                        children: [
                          Text(
                            _formatTimeAgo(widget.comment.createdAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colors.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              context.read<CommentBloc>().add(
                                AddReaction(
                                  commentId: widget.comment.commentId,
                                  reactionType: 'like',
                                  nodeId: widget.nodeId,
                                  pathId: widget.pathId,
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 14,
                                  color: isLiked
                                      ? Colors.red
                                      : colors.onSurface.withValues(alpha: 0.5),
                                ),
                                if (likeCount > 0) ...[
                                  const SizedBox(width: 3),
                                  Text(
                                    '$likeCount',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isLiked
                                              ? Colors.red
                                              : colors.onSurface.withValues(
                                                  alpha: 0.5,
                                                ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => widget.onReply(
                              widget.comment.commentId,
                              widget.comment.userName,
                            ),
                            child: Text(
                              'Reply',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.iconbar,
                                  ),
                            ),
                          ),
                          if (!widget.isNested &&
                              widget.replies.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showReplies = !_showReplies;
                                });
                              },
                              child: Text(
                                _showReplies
                                    ? 'Hide replies'
                                    : '${widget.replies.length} ${widget.replies.length == 1 ? "reply" : "replies"}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.iconbar,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Delete button
              if (isOwner)
                GestureDetector(
                  onTap: () {
                    ActionPopUp.show(
                      context,
                      onEdit: () => widget.onEdit(
                        widget.comment.commentId,
                        widget.comment.message,
                        widget.comment.userName,
                      ),
                      onDelete: widget.onDelete,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Icon(
                      Icons.more_horiz,
                      size: 18,
                      color: colors.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
            ],
          ),

          // Replies
          if (!widget.isNested && _showReplies && widget.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 46.0, top: 4.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.replies.length,
                itemBuilder: (context, index) {
                  final reply = widget.replies[index];
                  return _CommentItem(
                    comment: reply,
                    replies: const [],
                    nodeId: widget.nodeId,
                    pathId: widget.pathId,
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
                    onEdit: widget.onEdit,
                    onReply: widget.onReply,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
