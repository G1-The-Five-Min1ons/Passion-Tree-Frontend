import 'package:flutter/material.dart';

class TreeLayoutHelper {
  static Offset getOffset({
    required int index,
    required double canvasWidth,
    double verticalSpacing = 100.0,
    double horizontalShift = 120.0,
  }) {
    double centerX = canvasWidth / 2;
    double dy = 60.0 + (index * verticalSpacing);
    double dx = centerX;

    if (index % 3 == 1) dx = centerX - horizontalShift; // เยื้องซ้าย
    if (index % 3 == 2) dx = centerX + horizontalShift; //เยื้องขวา

    return Offset(dx, dy);
  }

  static Path createSCurvePath(Offset start, Offset end) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    double midY = (start.dy + end.dy) / 2;

    path.cubicTo(
      start.dx, midY, 
      end.dx, midY, 
      end.dx, end.dy,
    );
    return path;
  }
}


