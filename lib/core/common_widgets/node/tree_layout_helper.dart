import 'package:flutter/material.dart';

class TreeLayoutHelper {
  static Offset getOffset({
    required int index,
    required double canvasWidth,
    double verticalSpacing = 120.0,
    double nodeSize = 64.0,
  }) {
    final double centerX = canvasWidth / 2;
    final double horizontalShift = canvasWidth * 0.25;

    final double dy = 60.0 + (index * verticalSpacing);

    double dx = centerX;
    if (index % 3 == 1) dx = centerX - horizontalShift;
    if (index % 3 == 2) dx = centerX + horizontalShift;

    // clamp ตามขนาด node จริง
    dx = dx.clamp(nodeSize / 2, canvasWidth - nodeSize / 2);

    return Offset(dx, dy);
  }


  static Path createSCurvePath(Offset start, Offset end) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final double midY = (start.dy + end.dy) / 2;

    path.cubicTo(start.dx, midY, end.dx, midY, end.dx, end.dy);
    return path;
  }
}



