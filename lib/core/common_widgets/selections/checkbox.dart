import 'package:flutter/material.dart';

class PixelCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final double size;
  final Color? activeColor;
  final Color? borderColor;

  const PixelCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 24.0,
    this.activeColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeCheckColor = activeColor ?? colorScheme.primary;
    final activeBorderColor = borderColor ?? colorScheme.onSurface;

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: CustomPaint(
        size: Size(size, size),
        painter: _PixelCheckboxPainter(
          isChecked: value,
          checkColor: activeCheckColor,
          borderColor: activeBorderColor,
          backgroundColor: colorScheme.surface,
        ),
      ),
    );
  }
}

class _PixelCheckboxPainter extends CustomPainter {
  final bool isChecked;
  final Color checkColor;
  final Color borderColor;
  final Color backgroundColor;

  _PixelCheckboxPainter({
    required this.isChecked,
    required this.checkColor,
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = w / 8; // pixel size

    // Background
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(p, p, w - p * 2, h - p * 2), bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    // Top border
    canvas.drawRect(Rect.fromLTWH(p * 2, 0, w - p * 4, p), borderPaint);
    // Bottom border
    canvas.drawRect(Rect.fromLTWH(p * 2, h - p, w - p * 4, p), borderPaint);
    // Left border
    canvas.drawRect(Rect.fromLTWH(0, p * 2, p, h - p * 4), borderPaint);
    // Right border
    canvas.drawRect(Rect.fromLTWH(w - p, p * 2, p, h - p * 4), borderPaint);

    // Corners
    canvas.drawRect(Rect.fromLTWH(p, p, p, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - p * 2, p, p, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, h - p * 2, p, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - p * 2, h - p * 2, p, p), borderPaint);

    // Checkmark if checked
    if (isChecked) {
      final checkPaint = Paint()
        ..color = checkColor
        ..style = PaintingStyle.fill;

      // Draw pixel checkmark
      // Vertical part of checkmark
      canvas.drawRect(Rect.fromLTWH(w * 0.3, h * 0.5, p, p * 2), checkPaint);
      canvas.drawRect(Rect.fromLTWH(w * 0.4, h * 0.6, p, p * 1.5), checkPaint);
      // Diagonal part
      canvas.drawRect(Rect.fromLTWH(w * 0.5, h * 0.45, p, p * 1.5), checkPaint);
      canvas.drawRect(Rect.fromLTWH(w * 0.6, h * 0.3, p, p * 1.5), checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PixelCheckboxPainter oldDelegate) {
    return oldDelegate.isChecked != isChecked;
  }
}
