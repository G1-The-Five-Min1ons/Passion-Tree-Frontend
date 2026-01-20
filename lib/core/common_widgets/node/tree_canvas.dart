import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/dashed_line_painter.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_layout_helper.dart';

class TreeCanvas extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index, Offset position) nodeBuilder;
  final double canvasWidth;
  final Color? lineColor;

  const TreeCanvas({
    super.key,
    required this.itemCount,
    required this.nodeBuilder,
    required this.canvasWidth,
    this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveLineColor = lineColor ?? Theme.of(context).colorScheme.onPrimary;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. วาดเส้นเชื่อมโยงอัตโนมัติ
        for (int i = 0; i < itemCount - 1; i++)
          CustomPaint(
            painter: DashedLinePainter(
              path: TreeLayoutHelper.createSCurvePath(
                TreeLayoutHelper.getOffset(index: i, canvasWidth: canvasWidth),
                TreeLayoutHelper.getOffset(index: i + 1, canvasWidth: canvasWidth),
              ),
              color: effectiveLineColor,
            ),
          ),

        // 2. วางโหนดตามตำแหน่งอัตโนมัติ
        for (int i = 0; i < itemCount; i++)
          nodeBuilder(
            i, 
            TreeLayoutHelper.getOffset(index: i, canvasWidth: canvasWidth)
          ),
      ],
    );
  }
}