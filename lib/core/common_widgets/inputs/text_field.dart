import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';


// 2. ตัว Widget หลัก
class PixelTextField extends StatelessWidget {
  final String? label;
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
  final TextStyle? textStyle;
  final TextStyle? labelTextStyle;

  const PixelTextField({
    super.key,
    this.label,
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
    this.textStyle,
    this.labelTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ScrollController scrollController = ScrollController();
    final theme = Theme.of(context).textTheme;

    //ถ้าตอนเอาไปใช้ไม่ได้กำหนดสีมา ก็จะใช้สีจาก Theme ที่กำหนดไว้แล้วแทน
    final activeBorderColor = borderColor ?? colorScheme.primary;
    final activeLabelColor = labelColor ?? colorScheme.onSurface;
    final activeTextColor = textColor ?? colorScheme.onSurface;
    final activeHintColor = hintColor ?? AppColors.textSecondary.withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            label!,
            style: (labelTextStyle ?? AppTypography.titleSemiBold).copyWith(
              color: activeLabelColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
        
        PixelBorderContainer(
          width: width ?? double.infinity, 
          height: height,
          pixelSize: pixelSize,
          borderColor: activeBorderColor,
          fillColor: colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
          child: Scrollbar(
            controller: scrollController, 
            thumbVisibility: true,
            child: TextField(
              controller: controller,
              scrollController: scrollController,
              maxLines: null,
              expands: true, 
              obscureText: isPassword,
              style: (textStyle ?? AppTypography.bodyRegular).copyWith(
                color: activeTextColor,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: (textStyle ?? AppTypography.bodyRegular).copyWith(
                  color: activeHintColor,
                ),
                border: InputBorder.none, 
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//---------------------- วิธีเรียกใช้ ----------------------//
/*
            const PixelTextField(
              label: 'เทส', -- ชื่อหัวข้อข้างบน
              hintText: 'Summary', --ตัวอักษรข้างใน
              height: 46, -- จัดการความสูง บรรทัดเดียว 46 กำลังสวย
              //borderColor: Theme.of(context).colorScheme.error, -- ใส่เมื่อต้องการเปลี่ยนสีขอบ
            ),
*/