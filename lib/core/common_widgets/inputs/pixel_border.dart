import 'package:flutter/material.dart';

class PixelBorderContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double pixelSize;
  final Color? borderColor;
  final Color? fillColor;
  final Gradient? gradient; // optional gradient fill
  final EdgeInsetsGeometry padding;

  const PixelBorderContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.pixelSize = 3.0,
    this.borderColor,
    this.fillColor,
    this.gradient,
    this.padding = const EdgeInsets.all(12), 
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PixelBorderPainter(
                color: borderColor ?? Theme.of(context).colorScheme.primary,
                pixelSize: pixelSize,
                fillColor: fillColor ?? Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          // gradient overlay inside pixel border shape
          if (gradient != null)
            Positioned.fill(
              child: ClipPath(
                clipper: _PixelBorderClipper(pixelSize),
                child: Container(
                  decoration: BoxDecoration(gradient: gradient),
                ),
              ),
            ),
          // content
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Clips a child to the same pixel-notch shape as _PixelBorderPainter
/// so gradient overlays fit perfectly inside the border.
class _PixelBorderClipper extends CustomClipper<Path> {
  final double pixelSize;
  _PixelBorderClipper(this.pixelSize);

  @override
  Path getClip(Size size) {
    return _pixelBorderPath(size, inset: pixelSize, step: pixelSize);
  }

  @override
  bool shouldReclip(covariant _PixelBorderClipper oldClipper) {
    return oldClipper.pixelSize != pixelSize;
  }
}


class _PixelBorderPainter extends CustomPainter {
  final Color color;
  final double pixelSize;
  final Color fillColor;

  _PixelBorderPainter({
    required this.color, 
    required this.pixelSize, 
    required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final outerPath = _pixelBorderPath(size, inset: 0, step: pixelSize);
    final innerPath = _pixelBorderPath(
      size,
      inset: pixelSize,
      step: pixelSize,
    );

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerPath, fillPaint);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final borderPath = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PixelBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.pixelSize != pixelSize ||
        oldDelegate.fillColor != fillColor;
  }
}

Path _pixelBorderPath(Size size, {required double inset, required double step}) {
  final safeStep = step <= 0 ? 1.0 : step;
  final left = inset;
  final top = inset;
  final right = size.width - inset;
  final bottom = size.height - inset;

  return Path()
    ..moveTo(left + safeStep * 2, top)
    ..lineTo(right - safeStep * 2, top)
    ..lineTo(right - safeStep * 2, top + safeStep)
    ..lineTo(right - safeStep, top + safeStep)
    ..lineTo(right - safeStep, top + safeStep * 2)
    ..lineTo(right, top + safeStep * 2)
    ..lineTo(right, bottom - safeStep * 2)
    ..lineTo(right - safeStep, bottom - safeStep * 2)
    ..lineTo(right - safeStep, bottom - safeStep)
    ..lineTo(right - safeStep * 2, bottom - safeStep)
    ..lineTo(right - safeStep * 2, bottom)
    ..lineTo(left + safeStep * 2, bottom)
    ..lineTo(left + safeStep * 2, bottom - safeStep)
    ..lineTo(left + safeStep, bottom - safeStep)
    ..lineTo(left + safeStep, bottom - safeStep * 2)
    ..lineTo(left, bottom - safeStep * 2)
    ..lineTo(left, top + safeStep * 2)
    ..lineTo(left + safeStep, top + safeStep * 2)
    ..lineTo(left + safeStep, top + safeStep)
    ..lineTo(left + safeStep * 2, top + safeStep)
    ..close();
}