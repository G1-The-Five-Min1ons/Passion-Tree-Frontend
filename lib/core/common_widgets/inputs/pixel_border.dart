import 'package:flutter/material.dart';

class PixelBorderContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double pixelSize;
  final Color? borderColor;
  final Color? fillColor;
  final EdgeInsetsGeometry padding;

  const PixelBorderContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.pixelSize = 3.0,
    this.borderColor,
    this.fillColor,
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
          // ส่วนเนื้อหา
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
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