import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

// Custom painter for password field (same as PixelTextField but optimized for single line)
class _PixelPasswordBorderPainter extends CustomPainter {
  final Color color;
  final double pixelSize;
  final Color fillColor;

  _PixelPasswordBorderPainter({
    required this.color,
    required this.pixelSize,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;
    double p = pixelSize;
    double s = p * 0.5;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(p * 2, p * 2, w - (p * 4), h - (p * 4)), fillPaint);
    canvas.drawRect(Rect.fromLTWH(p * 3, 0, w - (p * 6), h), fillPaint);
    canvas.drawRect(Rect.fromLTWH(0, p * 3, w, h - (p * 6)), fillPaint);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Main borders
    canvas.drawRect(Rect.fromLTWH(p * 2, 0, w - (p * 4), p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(0, p * 2, p, h - (p * 4)), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - p - s, p * 2, p + s, h - (p * 4)), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p * 2, h - p - s, w - (p * 4), p + s), borderPaint);

    // Corners
    canvas.drawRect(Rect.fromLTWH(p * 2, p, p, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, p, p, p * 2), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, p * 2, p, p), borderPaint);

    canvas.drawRect(Rect.fromLTWH(w - (p * 3) - s, p, p, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, p, p + s, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, p * 2, p + s, p), borderPaint);

    canvas.drawRect(Rect.fromLTWH(p * 2, h - (p * 2) - s, p, p + s), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, h - (p * 2) - s, p, p + s), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, h - (p * 3) - s, p, p), borderPaint);

    canvas.drawRect(Rect.fromLTWH(w - (p * 3) - s, h - (p * 2) - s, p, p + s), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, h - (p * 2) - s, p + s, p + s), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, h - (p * 3) - s, p + s, p), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PixelPasswordField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final double height;
  final double? width;
  final double pixelSize;
  final Color? borderColor;
  final Color? labelColor;
  final Color? textColor;
  final Color? hintColor;

  const PixelPasswordField({
    super.key,
    required this.label,
    this.hintText = '',
    this.controller,
    this.obscureText = true,
    this.height = 46.0,
    this.width,
    this.pixelSize = 3.0,
    this.borderColor,
    this.labelColor,
    this.textColor,
    this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final activeBorderColor = borderColor ?? colorScheme.primary;
    final activeLabelColor = labelColor ?? colorScheme.onSurface;
    final activeTextColor = textColor ?? colorScheme.onSurface;
    final activeHintColor = hintColor ?? AppColors.textSecondary.withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            label,
            style: AppTypography.subtitleSemiBold.copyWith(
              color: activeLabelColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: Stack(
            children: [
              // Border painter
              IgnorePointer(
                child: CustomPaint(
                  size: Size(width ?? double.infinity, height),
                  painter: _PixelPasswordBorderPainter(
                    color: activeBorderColor,
                    pixelSize: pixelSize,
                    fillColor: colorScheme.surface,
                  ),
                ),
              ),
              
              // Text field
              Container(
                height: height,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: controller,
                  maxLines: 1,
                  obscureText: obscureText,
                  style: AppTypography.bodyRegular.copyWith(
                    color: activeTextColor,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(color: activeHintColor),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
