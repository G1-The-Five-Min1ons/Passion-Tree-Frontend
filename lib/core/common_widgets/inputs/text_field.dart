import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';


// 2. ตัว Widget หลัก
class PixelTextField extends StatefulWidget {
  final String? label;
  final String hintText;
  final String? value; 
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
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final int? maxLines;

  const PixelTextField({
    super.key,
    this.label,
    this.hintText = '',
    this.value, 
    this.controller,//ถ้าไม่ส่ง controller มา จะสร้างใหม่เอง
    this.isPassword = false,
    this.height = 56.0,
    this.width,
    this.pixelSize = 3.0,
    this.borderColor,
    this.labelColor,
    this.textColor,
    this.hintColor,
    this.textStyle,
    this.labelTextStyle,
    this.onChanged, //สำหรับเก็บฟังก์ชัน onChanged ไม่ส่งค่าก้ไม่เป้นไร
    this.obscureText = false,
    this.maxLines,
  });

  @override
  State<PixelTextField> createState() => _PixelTextFieldState();
}

class _PixelTextFieldState extends State<PixelTextField> {
  late final TextEditingController _controller;
  late final bool _useExternalController;

  @override
  void initState() {
    super.initState();

    _useExternalController = widget.controller != null;

    _controller =
        widget.controller ?? TextEditingController(text: widget.value ?? '');
  }

  @override
  void dispose() {
    if (!_useExternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PixelTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // sync value ใหม่ ถ้าไม่ได้ใช้ controller จากข้างนอก
    if (!_useExternalController &&
        widget.value != null &&
        widget.value != oldWidget.value) {
      _controller.text = widget.value!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ScrollController scrollController = ScrollController();

    //ถ้าตอนเอาไปใช้ไม่ได้กำหนดสีมา ก็จะใช้สีจาก Theme ที่กำหนดไว้แล้วแทน
    final activeBorderColor = widget.borderColor ?? colorScheme.primary;
    final activeLabelColor = widget.labelColor ?? colorScheme.onSurface;
    final activeTextColor = widget.textColor ?? colorScheme.onSurface;
    final activeHintColor =widget.hintColor ?? AppColors.textSecondary.withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: RichText(
              text: TextSpan(
                style: (widget.labelTextStyle ?? AppTypography.titleSemiBold).copyWith(color: activeLabelColor),
                children: [
                  TextSpan(text: widget.label!.replaceFirst('*', '').trim()),
                  if (widget.label!.contains('*'))
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: AppColors.cancel,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        PixelBorderContainer(
          width: widget.width ?? double.infinity,
          height: widget.height,
          pixelSize: widget.pixelSize,
          borderColor: activeBorderColor,
          fillColor: colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: TextField(
              controller: _controller,
              scrollController: scrollController,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              expands: widget.obscureText ? false : (widget.maxLines == null),
              obscureText: widget.obscureText,
              onChanged: widget.onChanged,
              style: (widget.textStyle ?? AppTypography.bodyRegular).copyWith(
                color: activeTextColor,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: (widget.textStyle ?? AppTypography.bodyRegular)
                    .copyWith(color: activeHintColor),
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
              height: 38, -- จัดการความสูง บรรทัดเดียว 38 กำลังสวย
              //borderColor: Theme.of(context).colorScheme.error, -- ใส่เมื่อต้องการเปลี่ยนสีขอบ
            ),
*/