import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'dart:math';

import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';

class AppButton extends StatefulWidget {
  final AppButtonVariant variant;
  final AppButtonSize size;
  final String? subText;
  final String? text;
  final Widget? icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  final bool fullWidth;

  const AppButton({
    super.key,
    required this.variant,
    required this.onPressed,
    this.subText,
    this.text,
    this.icon,
    this.size = AppButtonSize.small,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.fullWidth = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  static const double _pixel = 4;
  static const double _horizontalPadding = 40; // 20 + 20
  static const double _iconSize = 16;
  static const double _iconSpacing = 16;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bgColor = widget.backgroundColor ?? scheme.primary;
    final bdColor = widget.borderColor ?? AppColors.buttonBorder;
    final fgColor = widget.textColor ?? scheme.onPrimary;

    final TextStyle buttonTextStyle = AppPixelTypography.smallTitle.copyWith(
      color: fgColor,
    );

    final double buttonWidth = switch (widget.variant) {
      AppButtonVariant.iconOnly => _iconOnlyWidth(),
      AppButtonVariant.textWithIcon => _calculateWidthFromTextAndIcon(
        buttonTextStyle,
      ),
      AppButtonVariant.text => _calculateWidthFromText(buttonTextStyle),
      AppButtonVariant.leadingIconWithText => _calculateWidthFromTextAndIcon(
        buttonTextStyle,
      ),
    };

    return GestureDetector(
      onTap: widget.onPressed,
      child: PixelBorderContainer(
        padding: EdgeInsets.zero,
        fillColor: bgColor,
        borderColor: bdColor,
        child: SizedBox(
          width: widget.fullWidth ? double.infinity : buttonWidth,
          height: _height(),
          child: Center(child: _buildContent(buttonTextStyle)),
        ),
      ),
    );
  }

  // ===================================================
  // Content
  // ===================================================
  Widget _buildContent(TextStyle textStyle) {
    switch (widget.variant) {
      case AppButtonVariant.text:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text ?? '',
              style: textStyle,
              textAlign: TextAlign.center,
            ),
            if (widget.subText != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subText!,
                style: AppTypography.smallBodyMedium.copyWith(
                  color: textStyle.color?.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );

      case AppButtonVariant.leadingIconWithText:
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.icon ?? const SizedBox(),
            SizedBox(width: _getSpacing()),
            Text(widget.text ?? '', style: textStyle),
          ],
        );

      case AppButtonVariant.textWithIcon:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.text ?? '', style: textStyle),
            const SizedBox(width: _iconSpacing),
            widget.icon ?? const SizedBox(),
          ],
        );

      case AppButtonVariant.iconOnly:
        return widget.icon ?? const SizedBox();
    }
  }

  // ===================================================
  // Size & Width Calculation
  // ===================================================
  double _height() {
    if (widget.subText != null) {
      return 50; // ปุ่ม 2 บรรทัด
    }
    return 40; // ปุ่มปกติ
  }

  double _iconOnlyWidth() => 60;

  double _calculateWidthFromText(TextStyle style) {
    final mainPainter = TextPainter(
      text: TextSpan(text: widget.text ?? '', style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    double maxWidth = mainPainter.width;

    if (widget.subText != null) {
      final subPainter = TextPainter(
        text: TextSpan(
          text: widget.subText!,
          style: AppTypography.smallBodyMedium,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      maxWidth = max(maxWidth, subPainter.width);
    }

    final rawWidth = maxWidth + _horizontalPadding;
    return (rawWidth / _pixel).ceil() * _pixel;
  }

  double _calculateWidthFromTextAndIcon(TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: widget.text ?? '', style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final rawWidth =
        painter.width + _iconSize + _iconSpacing + _horizontalPadding;

    return (rawWidth / _pixel).ceil() * _pixel;
  }

  double _getSpacing() {
    return widget.variant == AppButtonVariant.leadingIconWithText
        ? 8
        : _iconSpacing;
  }
}

//---------------------- วิธีเรียกใช้ ----------------------//
// ===== Pixel Button =====
/* มี 3 แบบให้เลือกใช้
            -text only 
            AppButton(
              variant: AppButtonVariant.text,
              text: 'Text',
              onPressed: () {
                debugPrint('Submit pressed');
              },
            ),

            -textWithIcon
            AppButton(
              variant: AppButtonVariant.textWithIcon,
              text: 'Like',
              icon: const PixelIcon('assets/icons/Pixel_heart.png'),
              onPressed: () {},
            ),

            -icon only
            AppButton(
              variant: AppButtonVariant.iconOnly,
              icon: const PixelIcon('assets/icons/Pixel_plus.png', size: 16),
              onPressed: () {},
            ),
*/
