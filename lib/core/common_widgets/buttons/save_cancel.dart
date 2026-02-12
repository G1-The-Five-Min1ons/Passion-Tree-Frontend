import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class SaveCancel extends StatelessWidget{
  final VoidCallback? onSave;
  final Color? saveButtonColor;
  final Color? cancelButtonColor;
  final VoidCallback onCancel;
  final String saveText;
  final String cancelText;
  final Widget? saveIcon;

  const SaveCancel({
    super.key,
    this.onSave,
    this.saveButtonColor,
    this.cancelButtonColor,
    required this.onCancel,
    this.saveText = 'Save',
    this.cancelText = 'Cancel', 
    this.saveIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisable = onSave == null;
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
          AppButton(
            variant: AppButtonVariant.text,
            text: cancelText,
            onPressed: onCancel,
            backgroundColor:
              cancelButtonColor ?? AppColors.scale, 
          textColor: cancelButtonColor != null
              ? colors.onError
              : colors.onSurface,
          ),
        
        const SizedBox(width: 8),

        AppButton(
          variant: saveIcon != null 
              ? AppButtonVariant.textWithIcon
              : AppButtonVariant.text,
          text: saveText,
          icon: saveIcon,
          onPressed: onSave ?? () {},
          backgroundColor: isDisable 
            ? AppColors.textDisabled
            : (saveButtonColor ?? Theme.of(context).colorScheme.primary),
          textColor: saveButtonColor != null 
              ? Colors.white 
              : Theme.of(context).colorScheme.onPrimary,
        ),
      ],
    );
  }
}