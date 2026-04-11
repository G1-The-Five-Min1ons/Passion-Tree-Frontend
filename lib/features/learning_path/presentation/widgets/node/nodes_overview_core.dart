import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/node_item.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_canvas.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_asset.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_state.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';

class NodesOverviewCore extends StatefulWidget {
  final bool isEditable;
  final bool isDraggable;
  final Function(int index)? onNodeTap;
  final Function(int fromIndex, int toIndex)? onReorder;
  final List<NodeDetail>? nodes;

  const NodesOverviewCore({
    super.key,
    required this.isEditable,
    this.isDraggable = false,
    this.onNodeTap,
    this.onReorder,
    this.nodes,
  });

  @override
  State<NodesOverviewCore> createState() => _NodesOverviewCoreState();
}

class _NodesOverviewCoreState extends State<NodesOverviewCore> {
  int? _draggingIndex;
  int? _hoverIndex;

  @override
  Widget build(BuildContext context) {
    final displayNodes = widget.nodes ?? [];
    final nodeCount = displayNodes.length;
    final canvasHeight = (nodeCount * 200.0) + 200.0;

    NodeDetail? latestActiveNode;
    for (final node in displayNodes) {
      if (node.status.toLowerCase() == 'active') {
        if (latestActiveNode == null ||
            node.sequence > latestActiveNode.sequence) {
          latestActiveNode = node;
        }
      }
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xmargin),
          child: Column(
            children: [
              const SizedBox(height: 140),
              LayoutBuilder(
                builder: (context, constraints) {
                  final canvasWidth = constraints.maxWidth;

                  return SizedBox(
                    height: canvasHeight,
                    child: TreeCanvas(
                      itemCount: nodeCount,
                      canvasWidth: canvasWidth,
                      nodeBuilder: (index, pos) {
                        final node = displayNodes[index];
                        final hasTeacherContent =
                            widget.isEditable && _hasNodeContent(node);
                        final nodeState = hasTeacherContent
                            ? LearningNodeState.active
                            : NodeAsset.statusToState(node.status);

                        final isLatestActiveNode =
                            latestActiveNode != null &&
                            node.nodeId == latestActiveNode.nodeId;

                        final nodeWidget = NodeItem(
                          imagePath: NodeAsset.image(nodeState),
                          size: 80,
                          showCurrentIndicator: isLatestActiveNode,
                          onTap: _draggingIndex != null
                              ? null
                              : () => widget.onNodeTap?.call(index),
                        );

                        if (!widget.isDraggable) {
                          return Positioned(
                            left: pos.dx - 40,
                            top: pos.dy - 40,
                            child: nodeWidget,
                          );
                        }

                        // ===== DRAG TARGET =====
                        return Positioned(
                          left: pos.dx - 40,
                          top: pos.dy - 40,
                          child: DragTarget<int>(
                            onWillAcceptWithDetails: (details) {
                              if (details.data == index) return false;
                              setState(() => _hoverIndex = index);
                              return true;
                            },
                            onLeave: (_) {
                              setState(() => _hoverIndex = null);
                            },
                            onAcceptWithDetails: (details) {
                              setState(() {
                                _hoverIndex = null;
                                _draggingIndex = null;
                              });
                              widget.onReorder?.call(details.data, index);
                            },
                            builder: (context, candidateData, rejectedData) {
                              final isHovered = _hoverIndex == index;
                              final isDragging = _draggingIndex == index;

                              return AnimatedOpacity(
                                duration: const Duration(milliseconds: 150),
                                opacity: isDragging ? 0.3 : 1.0,
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 150),
                                  scale: isHovered ? 1.2 : 1.0,
                                  child: LongPressDraggable<int>(
                                    data: index,
                                    delay: const Duration(milliseconds: 300),
                                    onDragStarted: () {
                                      setState(() => _draggingIndex = index);
                                    },
                                    onDragEnd: (_) {
                                      setState(() => _draggingIndex = null);
                                    },
                                    onDraggableCanceled: (_, __) {
                                      setState(() => _draggingIndex = null);
                                    },
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: Transform.scale(
                                        scale: 1.15,
                                        child: Opacity(
                                          opacity: 0.85,
                                          child: Image.asset(
                                            NodeAsset.image(nodeState),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.contain,
                                            filterQuality: FilterQuality.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.2,
                                      child: nodeWidget,
                                    ),
                                    child: nodeWidget,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 320),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasNodeContent(NodeDetail node) {
    final hasDescription = node.description.trim().isNotEmpty;
    final hasVideoLink = (node.linkVdo ?? '').trim().isNotEmpty;
    final hasMaterials = node.materials.any((m) => m.url.trim().isNotEmpty);
    final hasQuestions = node.questions.any(
      (q) =>
          q.questionText.trim().isNotEmpty ||
          q.choices.any((c) => c.choiceText.trim().isNotEmpty),
    );

    return hasDescription || hasVideoLink || hasMaterials || hasQuestions;
  }
}
