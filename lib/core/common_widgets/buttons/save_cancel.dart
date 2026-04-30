import 'dart:math';

import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class SaveCancel extends StatelessWidget{
  final VoidCallback? onSave;
  final Color? saveButtonColor;
  final Color? cancelButtonColor;
  final Color? cancelTextColor;
  final VoidCallback onCancel;
  final String saveText;
  final String cancelText;
  final Widget? saveIcon;

  const SaveCancel({
    super.key,
    this.onSave,
    this.saveButtonColor,
    this.cancelButtonColor,
    this.cancelTextColor,
    required this.onCancel,
    this.saveText = 'Save',
    this.cancelText = 'Cancel', 
    this.saveIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisable = onSave == null;
    final colors = Theme.of(context).colorScheme;
    const double minButtonWidth = 80;

    final buttonTextStyle = AppPixelTypography.smallTitle.copyWith(
      color: colors.onPrimary,
    );
    final saveButtonWidth = _calculateButtonWidth(
      text: saveText,
      style: buttonTextStyle,
      withIcon: saveIcon != null,
    );
    final cancelButtonWidth = _calculateButtonWidth(
      text: cancelText,
      style: buttonTextStyle,
    );
    final sharedButtonWidth = max(
      minButtonWidth,
      max(saveButtonWidth, cancelButtonWidth),
    );

    return Align(
      alignment: Alignment.centerRight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: sharedButtonWidth,
              child: AppButton(
                variant: saveIcon != null
                    ? AppButtonVariant.textWithIcon
                    : AppButtonVariant.text,
                text: saveText,
                icon: saveIcon,
                onPressed: onSave ?? () {},
                fullWidth: true,
                backgroundColor: isDisable
                    ? AppColors.textDisabled
                    : (saveButtonColor ?? Theme.of(context).colorScheme.primary),
                textColor: saveButtonColor != null
                    ? AppColors.textPrimary
                    : Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: sharedButtonWidth,
              child: AppButton(
                variant: AppButtonVariant.text,
                text: cancelText,
                onPressed: onCancel,
                fullWidth: true,
                backgroundColor: cancelButtonColor ?? AppColors.scale,
                textColor: cancelTextColor ?? (cancelButtonColor != null
                    ? colors.onError
                    : AppColors.background),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateButtonWidth({
    required String text,
    required TextStyle style,
    bool withIcon = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final contentWidth = painter.width + (withIcon ? 16 + 16 : 0) + 40;
    return (contentWidth / 4).ceil() * 4;
  }
}