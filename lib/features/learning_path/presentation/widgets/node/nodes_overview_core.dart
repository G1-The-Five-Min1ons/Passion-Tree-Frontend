import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/node_item.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_canvas.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_asset.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_state.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';

class NodesOverviewCore extends StatefulWidget {
  final bool isEditable;
  final bool isDraggable;
  final bool showAddBetween;
  final bool forceLockedStyle;
  final bool showNodeTitle;
  final double nodeSize;
  final String? description;
  final Function(int index)? onNodeTap;
  final Function(int fromIndex, int toIndex)? onReorder;
  final Function(int afterIndex)? onAddNodeAfter;
  final List<NodeDetail>? nodes;

  const NodesOverviewCore({
    super.key,
    required this.isEditable,
    this.isDraggable = false,
    this.showAddBetween = false,
    this.forceLockedStyle = false,
    this.showNodeTitle = false,
    this.nodeSize = 75,
    this.description,
    this.onNodeTap,
    this.onReorder,
    this.onAddNodeAfter,
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
    final description = widget.description?.trim() ?? '';
    const verticalSpacing = 120.0;
    const topCanvasInset = 20.0;

    // 1. เพิ่มค่านี้เพื่อให้พื้นหลังสีน้ำเงิน/เส้นประ วาดลากยาวลงไปใต้ Node สุดท้ายจนถึงขอบ App Bar
    const bottomCanvasInset = 10.0;

    final dynamicCanvasHeight = nodeCount == 0
        ? 200.0
        : topCanvasInset +
              ((nodeCount - 1) * verticalSpacing) +
              widget.nodeSize +
              bottomCanvasInset;

    // --- Logic การหา Node ปัจจุบัน (คงเดิม) ---
    NodeDetail? latestActiveNode;
    for (final node in displayNodes) {
      if (node.status.toLowerCase() == 'active') {
        if (latestActiveNode == null ||
            node.sequence > latestActiveNode.sequence) {
          latestActiveNode = node;
        }
      }
    }

    NodeDetail? nextRequiredNode;
    if (!widget.isEditable) {
      for (final node in displayNodes) {
        if (node.complete.toLowerCase() != 'true') {
          if (nextRequiredNode == null ||
              node.sequence < nextRequiredNode.sequence) {
            nextRequiredNode = node;
          }
        }
      }
    }

    return Column(
      children: [
        if (description.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xmargin,
              0,
              AppSpacing.xmargin,
              12,
            ),
            child: PixelBorderContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              borderColor: AppColors.cardBorder,
              fillColor: AppColors.surface,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A3660), AppColors.surface],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: AppTypography.bodySemiBold.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        Expanded(
          child: Padding(
            // 2. ปรับเป็น 0.0 เพื่อให้พื้นที่วาดภาพ (Expanded) ชนขอบ App Bar ล่างพอดี
            padding: const EdgeInsets.only(bottom: 0.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fixedAreaHeight = constraints.maxHeight;
                final canvasWidth = constraints.maxWidth;
                final startYOffset = widget.isEditable
                    ? math.max(110.0, fixedAreaHeight * 0.16)
                    : 60.0;

                // 3. ใช้ความสูงที่ยาวที่สุดเพื่อให้พื้นหลังสีน้ำเงินแผ่เต็มหน้าจอเสมอ
                final finalCanvasHeight = math.max(
                  fixedAreaHeight,
                  dynamicCanvasHeight,
                );

                return SingleChildScrollView(
                  // physics นี้ทำให้เลื่อนได้นุ่มนวลและไถลงไปดูพื้นหลังด้านล่างได้เสมอ
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xmargin,
                  ),
                  child: SizedBox(
                    height: finalCanvasHeight,
                    width: canvasWidth,
                    child: TreeCanvas(
                      itemCount: nodeCount,
                      canvasWidth: canvasWidth,
                      startYOffset: startYOffset,
                      showAddBetween:
                          widget.showAddBetween && _draggingIndex == null,
                      onAddNodeAfter: widget.onAddNodeAfter,
                      nodeBuilder: (index, pos) {
                        final node = displayNodes[index];
                        final hasTeacherContent =
                            widget.isEditable && _hasNodeContent(node);
                        final nodeState = widget.forceLockedStyle
                            ? LearningNodeState.locked
                            : hasTeacherContent
                            ? LearningNodeState.active
                            : NodeAsset.statusToState(node.status);

                        final indicatorTargetNode = widget.isEditable
                            ? latestActiveNode
                            : (nextRequiredNode ?? latestActiveNode);

                        final isLatestActiveNode =
                            indicatorTargetNode != null &&
                            node.nodeId == indicatorTargetNode.nodeId;

                        final nodeWidget = NodeItem(
                          imagePath: NodeAsset.image(nodeState),
                          size: widget.nodeSize,
                          title: widget.showNodeTitle
                              ? _shortNodeTitle(node.title)
                              : null,
                          showCurrentIndicator: isLatestActiveNode,
                          onTap: _draggingIndex != null
                              ? null
                              : () => widget.onNodeTap?.call(index),
                        );

                        if (!widget.isDraggable) {
                          return Positioned(
                            left: pos.dx - widget.nodeSize / 2,
                            top: pos.dy - widget.nodeSize / 2,
                            child: nodeWidget,
                          );
                        }

                        // ===== ส่วน Drag & Drop สำหรับครู (คงเดิม) =====
                        return Positioned(
                          left: pos.dx - widget.nodeSize / 2,
                          top: pos.dy - widget.nodeSize / 2,
                          child: DragTarget<int>(
                            onWillAcceptWithDetails: (details) {
                              if (details.data == index) return false;
                              setState(() => _hoverIndex = index);
                              return true;
                            },
                            onLeave: (_) => setState(() => _hoverIndex = null),
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
                                    onDragStarted: () =>
                                        setState(() => _draggingIndex = index),
                                    onDragEnd: (_) =>
                                        setState(() => _draggingIndex = null),
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: Transform.scale(
                                        scale: 1.15,
                                        child: Opacity(
                                          opacity: 0.85,
                                          child: Image.asset(
                                            NodeAsset.image(nodeState),
                                            width: widget.nodeSize,
                                            height: widget.nodeSize,
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
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper Methods ---
  bool _hasNodeContent(NodeDetail node) {
    final normalizedTitle = node.title.trim().toLowerCase();
    final hasMeaningfulTitle =
        normalizedTitle.isNotEmpty && normalizedTitle != 'new node';
    final hasDescription = node.description.trim().isNotEmpty;
    final hasVideoLink = (node.linkVdo ?? '').trim().isNotEmpty;
    final hasMaterials = node.materials.any((m) => m.url.trim().isNotEmpty);
    final hasQuestions = node.questions.any(
      (q) =>
          q.questionText.trim().isNotEmpty ||
          q.choices.any((c) => c.choiceText.trim().isNotEmpty),
    );
    return hasMeaningfulTitle ||
        hasDescription ||
        hasVideoLink ||
        hasMaterials ||
        hasQuestions;
  }

  String _shortNodeTitle(String title) {
    final normalized = title.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) return 'Untitled';
    if (normalized.length <= 18) return normalized;
    return '${normalized.substring(0, 18)}...';
  }
}
