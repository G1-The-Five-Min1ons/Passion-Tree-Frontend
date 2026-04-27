import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class DashedLinePainter extends CustomPainter {
  final Path path;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final Offset? gapCenter;
  final double gapRadius;

  DashedLinePainter({
    required this.path,
    required this.color,
    this.strokeWidth = 4.0,
    this.dashWidth = 8.0,
    this.dashSpace = 8.0,
    this.gapCenter,
    this.gapRadius = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (ui.PathMetric measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        final start = distance;
        final end = (distance + dashWidth).clamp(0.0, measurePath.length);

        bool shouldDraw = true;
        if (gapCenter != null) {
          final midOffset = (start + end) / 2;
          final tangent = measurePath.getTangentForOffset(midOffset);
          final midPoint = tangent?.position;
          if (midPoint != null &&
              (midPoint - gapCenter!).distance <= gapRadius) {
            shouldDraw = false;
          }
        }

        if (shouldDraw) {
          canvas.drawPath(measurePath.extractPath(start, end), paint);
        }

        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.gapCenter != gapCenter ||
        oldDelegate.gapRadius != gapRadius;
  }
}
