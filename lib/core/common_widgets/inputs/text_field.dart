import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';


// 1. ตัววาดขอบหยัก
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



// 2. ตัว Widget หลัก
class PixelTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final double height;
  final double? width;
  final double pixelSize;
  final Color? borderColor;
  final Color? labelColor;
  final Color? textColor;
  final Color? hintColor;

  const PixelTextField({
    super.key,
    required this.label,
    this.hintText = '',
    this.controller,
    this.isPassword = false,
    this.height = 56.0,
    this.width,
    this.pixelSize = 3.0, // ความหนาของขอบพิกเซล
    this.borderColor,
    this.labelColor,
    this.textColor,
    this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ScrollController scrollController = ScrollController();

    //ถ้าตอนเอาไปใช้ไม่ได้กำหนดสีมา ก็จะใช้สีจาก Theme ที่กำหนดไว้แล้วแทน
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
        
        // ใช้ SizedBox หุ้มเพื่อควบคุมความกว้างที่รับมาจาก Constructor
        SizedBox(
          width: width ?? double.infinity, 
          height: height,
          child: Stack(
          children: [
            // ชั้นที่ 2: วาดขอบหยัก
            IgnorePointer(
              child: CustomPaint(
                size: Size(width ?? double.infinity, height),
                painter: _PixelBorderPainter(
                  color: activeBorderColor,
                  pixelSize: pixelSize,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
            
            // ชั้นที่ 3: ช่องกรอกข้อความ
              Container(
                height: height,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                alignment: Alignment.topLeft,
                child: Scrollbar(
                  controller: scrollController, 
                  thumbVisibility: true,
                child: TextField(
                  controller: controller,
                  scrollController: scrollController,
                  maxLines: null,
                  expands: true, 
                  obscureText: isPassword,
                  style: AppTypography.bodyRegular.copyWith(
                    color: activeTextColor,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(color: activeHintColor),
                    border: InputBorder.none, // ซ่อนขอบเดิม
                    isDense: true,
                    ),
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

//---------------------- วิธีเรียกใช้ ----------------------//
/*
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30), -- กันขอบกล่องติดขอบจอเกินไป
              child: PixelTextField(
                label: 'เทส', -- ชื่อหัวข้อข้างบน
                hintText: 'Summary', --ตัวอักษรข้างใน
                height: 46, -- จัดการความสูง บรรทัดเดียว 46 กำลังสวย
                //borderColor: Theme.of(context).colorScheme.error, -- ใส่เมื่อต้องการเปลี่ยนสีขอบ
              ),
            ),
*/