import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/dashed_line_painter.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_layout_helper.dart';

class TreeCanvas extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index, Offset position) nodeBuilder;
  final double canvasWidth;
  final Color? lineColor;
  final bool showAddBetween;
  final Function(int afterIndex)? onAddNodeAfter;
  final double startYOffset;

  const TreeCanvas({
    super.key,
    required this.itemCount,
    required this.nodeBuilder,
    required this.canvasWidth,
    this.lineColor,
    this.showAddBetween = false,
    this.onAddNodeAfter,
    this.startYOffset = 60.0,
  });

  Offset _addButtonCenter({
    required Offset from,
    required Offset to,
    required bool isLast,
  }) {
    if (isLast) {
      return Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    }

    final path = TreeLayoutHelper.createSCurvePath(from, to);
    final metric = path.computeMetrics().isNotEmpty
        ? path.computeMetrics().first
        : null;
    final tangent = metric?.getTangentForOffset((metric.length) / 2);
    return tangent?.position ??
        Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
  }

  @override
  Widget build(BuildContext context) {
    final Color effectiveLineColor =
        lineColor ?? Theme.of(context).colorScheme.onPrimary;

    return SizedBox(
      width: canvasWidth,
      height: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // เส้น
          for (int i = 0; i < itemCount - 1; i++)
            Builder(
              builder: (context) {
                final from = TreeLayoutHelper.getOffset(
                  index: i,
                  canvasWidth: canvasWidth,
                  startYOffset: startYOffset,
                );
                final to = TreeLayoutHelper.getOffset(
                  index: i + 1,
                  canvasWidth: canvasWidth,
                  startYOffset: startYOffset,
                );
                final connectorPath = TreeLayoutHelper.createSCurvePath(
                  from,
                  to,
                );
                final addCenter = showAddBetween
                    ? _addButtonCenter(from: from, to: to, isLast: false)
                    : null;

                return CustomPaint(
                  size: Size(canvasWidth, double.infinity),
                  painter: DashedLinePainter(
                    path: connectorPath,
                    color: effectiveLineColor,
                    gapCenter: addCenter,
                    gapRadius: 20,
                  ),
                );
              },
            ),

          // nodes
          for (int i = 0; i < itemCount; i++)
            nodeBuilder(
              i,
              TreeLayoutHelper.getOffset(
                index: i,
                canvasWidth: canvasWidth,
                startYOffset: startYOffset,
              ),
            ),

          // "+" buttons between nodes
          if (showAddBetween)
            for (int i = 0; i < itemCount; i++)
              Builder(
                builder: (context) {
                  final pos = TreeLayoutHelper.getOffset(
                    index: i,
                    canvasWidth: canvasWidth,
                    startYOffset: startYOffset,
                  );
                  Offset nextPos;
                  if (i < itemCount - 1) {
                    nextPos = TreeLayoutHelper.getOffset(
                      index: i + 1,
                      canvasWidth: canvasWidth,
                      startYOffset: startYOffset,
                    );
                  } else {
                    // For the last node, place "+" button below it
                    nextPos = Offset(pos.dx, pos.dy + 120.0);
                  }
                  final center = _addButtonCenter(
                    from: pos,
                    to: nextPos,
                    isLast: i == itemCount - 1,
                  );
                  return Positioned(
                    left: center.dx - 16,
                    top: center.dy - 16,
                    child: GestureDetector(
                      onTap: () => onAddNodeAfter?.call(i),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
}
