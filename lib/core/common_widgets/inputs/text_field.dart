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

    // --- ส่วนที่ 1: เส้นขอบตรงหลัก (ปรับให้ Overlap เข้าไปในหยัก) ---
    canvas.drawRect(Rect.fromLTWH(p * 3, 0, w - (p * 6), p), paint); // บน
    canvas.drawRect(Rect.fromLTWH(p * 3, h - p, w - (p * 6), p), paint); // ล่าง
    canvas.drawRect(Rect.fromLTWH(0, p * 3, p, h - (p * 6)), paint); // ซ้าย
    canvas.drawRect(Rect.fromLTWH(w - p, p * 3, p, h - (p * 6)), paint); // ขวา

    // --- ส่วนที่ 2: วาดรอยหยัก 4 ขั้นมุม ---
    // มุมบนซ้าย
    canvas.drawRect(Rect.fromLTWH(p * 3, p, p, p), paint);
    canvas.drawRect(Rect.fromLTWH(p * 2, p, p, p * 2), paint); 
    canvas.drawRect(Rect.fromLTWH(p, p * 2, p, p * 2), paint); 
    canvas.drawRect(Rect.fromLTWH(p, p * 3, p, p), paint);

    // มุมบนขวา
    canvas.drawRect(Rect.fromLTWH(w - (p * 4), p, p, p), paint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 3), p, p, p * 2), paint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2), p * 2, p, p * 2), paint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2), p * 3, p, p), paint);

    // มุมล่างซ้าย
    canvas.drawRect(Rect.fromLTWH(p * 3, h - (p * 2), p, p), paint);
    canvas.drawRect(Rect.fromLTWH(p * 2, h - (p * 3), p, p * 2), paint);
    canvas.drawRect(Rect.fromLTWH(p, h - (p * 4), p, p * 2), paint);
    canvas.drawRect(Rect.fromLTWH(p, h - (p * 4), p, p), paint);

    // มุมล่างขวา
    canvas.drawRect(Rect.fromLTWH(w - (p * 4), h - (p * 2), p, p), paint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 3), h - (p * 3), p, p * 2), paint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2), h - (p * 4), p, p * 2), paint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2), h - (p * 4), p, p), paint);
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
        // แสดง Label (เรียกใช้สีจาก onSurface ใน Theme)
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
            // ชั้นที่ 1: พื้นหลัง (เรียกใช้สี surface จาก Theme)
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
                  pixelSize: 4, // ความหนาของขอบพิกเซล
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
                  hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
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