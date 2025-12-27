import 'package:flutter/material.dart';
import '../../theme/typography.dart';

// 1. ตัววาดขอบหยัก
class _PixelBorderPainter extends CustomPainter {
  final Color color;
  final double pixelSize;

  _PixelBorderPainter({required this.color, required this.pixelSize});

  @override
void paint(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  double w = size.width;
  double h = size.height;
  double p = pixelSize;
  double s = p * 0.5; //ความหนาของขอบที่เพิ่มมา

  // --- 1. เส้นขอบตรงหลัก ---
  canvas.drawRect(Rect.fromLTWH(p * 3, 0, w - (p * 6), p), paint); // บน 
  canvas.drawRect(Rect.fromLTWH(0, p * 3, p, h - (p * 6)), paint); // ซ้าย 
  
  //เพิ่มความหนา
  canvas.drawRect(Rect.fromLTWH(w - p - s, p * 3, p + s, h - (p * 6)), paint); // ขวา
  canvas.drawRect(Rect.fromLTWH(p * 3, h - p - s, w - (p * 6), p + s), paint); // ล่าง

  // --- 2. รอยหยักมุม ---
  // มุมบนซ้าย
  canvas.drawRect(Rect.fromLTWH(p * 3, p, p, p), paint);
  canvas.drawRect(Rect.fromLTWH(p * 2, p, p, p * 2), paint); 
  canvas.drawRect(Rect.fromLTWH(p, p * 2, p, p * 2), paint); 
  canvas.drawRect(Rect.fromLTWH(p, p * 3, p, p), paint);

  // มุมบนขวา (เพิ่มความหนา)
  canvas.drawRect(Rect.fromLTWH(w - (p * 4), p, p, p), paint);
  canvas.drawRect(Rect.fromLTWH(w - (p * 3), p, p, p * 2), paint);
  canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, p * 2, p + s, p * 2), paint);
  canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, p * 3, p + s, p), paint);

  // มุมล่างซ้าย (เพิ่มความหนา)
  canvas.drawRect(Rect.fromLTWH(p * 3, h - (p * 2) - s, p, p + s), paint);
  canvas.drawRect(Rect.fromLTWH(p * 2, h - (p * 3) - s, p, p * 2 + s), paint);
  canvas.drawRect(Rect.fromLTWH(p, h - (p * 4), p, p * 2), paint);
  canvas.drawRect(Rect.fromLTWH(p, h - (p * 4), p, p), paint);

  // มุมล่างขวา (เพิ่มความหนา)
  canvas.drawRect(Rect.fromLTWH(w - (p * 4), h - (p * 2) - s, p, p + s), paint);
  canvas.drawRect(Rect.fromLTWH(w - (p * 3), h - (p * 3) - s, p, p * 2 + s), paint);
  canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, h - (p * 4), p + s, p * 2), paint);
  canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, h - (p * 4), p + s, p), paint);
}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



// 2. ตัว Widget หลัก
class PixelTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final double height;

  const PixelTextField({
    super.key,
    required this.label,
    this.hintText = '',
    this.controller,
    this.isPassword = false,
    this.height = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.subtitleSemiBold.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        
        // ใช้ Stack เพื่อให้ Painter วาดทับบนพื้นหลังได้
        Stack(
          children: [
            // ชั้นที่ 1: พื้นหลัง 
            Container(
              height: height,
              decoration: BoxDecoration(
                color: colorScheme.surface,
              ),
            ),
            
            // ชั้นที่ 2: วาดขอบหยัก
            IgnorePointer(
              child: CustomPaint(
                size: Size(double.infinity, height),
                painter: _PixelBorderPainter(
                  color: colorScheme.primary, 
                  pixelSize: 3, // ความหนาของขอบพิกเซล
                ),
              ),
            ),
            
            // ชั้นที่ 3: ช่องกรอกข้อความ
            Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: TextField(
                controller: controller,
                obscureText: isPassword,
                style: AppTypography.bodyRegular.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  border: InputBorder.none, // ซ่อนขอบเดิม
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}