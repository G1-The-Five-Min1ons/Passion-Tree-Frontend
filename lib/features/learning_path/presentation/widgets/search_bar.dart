import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

// ตัววาดขอบหยักสำหรับ Search Bar
class _SearchBarBorderPainter extends CustomPainter {
  final Color color;
  final double pixelSize;
  final Color fillColor;

  _SearchBarBorderPainter({
    required this.color,
    required this.pixelSize,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;
    double p = pixelSize;
    double s = p * 0.5; //ความหนาของขอบที่เพิ่มมา

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(p * 2, p * 2, w - (p * 4), h - (p * 4)), fillPaint);
    canvas.drawRect(Rect.fromLTWH(p * 3, 0, w - (p * 6), h), fillPaint);
    canvas.drawRect(Rect.fromLTWH(0, p * 3, w, h - (p * 6)), fillPaint);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // --- 1. เส้นขอบตรงหลัก ---
    canvas.drawRect(Rect.fromLTWH(p * 2, 0, w - (p * 4), p), borderPaint); // บน
    canvas.drawRect(Rect.fromLTWH(0, p * 2, p, h - (p * 4)), borderPaint); // ซ้าย

    //เพิ่มความหนา
    canvas.drawRect(Rect.fromLTWH(w - p - s, p * 2, p + s, h - (p * 4)), borderPaint); // ขวา
    canvas.drawRect(Rect.fromLTWH(p * 2, h - p - s, w - (p * 4), p + s), borderPaint); // ล่าง

    // --- 2. รอยหยักมุม ---
    // มุมบนซ้าย
    canvas.drawRect(Rect.fromLTWH(p * 2, p, p, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, p, p, p * 2), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, p * 2, p, p), borderPaint);

    // มุมบนขวา (เพิ่มความหนา)
    canvas.drawRect(Rect.fromLTWH(w - (p * 3) - s, p, p, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, p, p + s, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, p * 2, p + s, p), borderPaint);

    // มุมล่างซ้าย (เพิ่มความหนา)
    canvas.drawRect(Rect.fromLTWH(p * 2, h - (p * 2) - s, p, p + s), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, h - (p * 2) - s, p, p + s), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, h - (p * 3) - s, p, p), borderPaint);

    // มุมล่างขวา (เพิ่มความหนา)
    canvas.drawRect(Rect.fromLTWH(w - (p * 3) - s, h - (p * 2) - s, p, p + s), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, h - (p * 2) - s, p + s, p + s), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, h - (p * 3) - s, p + s, p), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LearningPathSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double height;
  final double pixelSize;
  final Color? borderColor;
  final Color? textColor;
  final Color? hintColor;

  const LearningPathSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Find learning paths...',
    this.height = 46.0,
    this.pixelSize = 3.0,
    this.borderColor,
    this.textColor,
    this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ScrollController scrollController = ScrollController();

    final activeBorderColor = borderColor ?? colorScheme.primary;
    final activeTextColor = textColor ?? colorScheme.onSurface;
    final activeHintColor = hintColor ?? AppColors.textSecondary.withValues(alpha: 0.5);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // วาดขอบหยัก
          IgnorePointer(
            child: CustomPaint(
              size: Size(double.infinity, height),
              painter: _SearchBarBorderPainter(
                color: activeBorderColor,
                pixelSize: pixelSize,
                fillColor: colorScheme.surface,
              ),
            ),
          ),

          // ช่องกรอกข้อความ
          Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                // Search Icon
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Image.asset(
                    'assets/icons/search.png',
                    width: 20,
                    height: 20,
                    color: activeTextColor.withValues(alpha: 0.6),
                  ),
                ),
                // TextField
                Expanded(
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: TextField(
                      controller: controller,
                      scrollController: scrollController,
                      maxLines: null,
                      expands: true,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
