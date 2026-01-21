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
    final Color effectiveLineColor =
        lineColor ?? Theme.of(context).colorScheme.onPrimary;

    return SizedBox(
      width: canvasWidth, //บังคับขนาด
      height: double.infinity, // (SizedBox หน้า page) คุมความสูง
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // เส้น
          for (int i = 0; i < itemCount - 1; i++)
            CustomPaint(
              size: Size(canvasWidth, double.infinity), 
              painter: DashedLinePainter(
                path: TreeLayoutHelper.createSCurvePath(
                  TreeLayoutHelper.getOffset(
                    index: i,
                    canvasWidth: canvasWidth,
                  ),
                  TreeLayoutHelper.getOffset(
                    index: i + 1,
                    canvasWidth: canvasWidth,
                  ),
                ),
                color: effectiveLineColor,
              ),
            ),

          // nodes
          for (int i = 0; i < itemCount; i++)
            nodeBuilder(
              i,
              TreeLayoutHelper.getOffset(index: i, canvasWidth: canvasWidth),
            ),
        ],
      ),
    );
  }
}
