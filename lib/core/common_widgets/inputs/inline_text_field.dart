import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class InlineTextField extends StatelessWidget {
  final String? hintText;
  final String? value;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;
  final bool showUnderline;
  final EdgeInsets padding;

  const InlineTextField({
    super.key,
    this.hintText,
    this.value,
    this.onChanged,
    this.textStyle,
    this.showUnderline = true,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: padding,
      decoration: showUnderline
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.scale.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
            )
          : null,
      child: TextField(
        controller: value != null
            ? TextEditingController.fromValue(
                TextEditingValue(
                  text: value!,
                  selection: TextSelection.collapsed(offset: value!.length),
                ),
              )
            : null,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyRegular.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: textStyle ?? AppTypography.bodyRegular,
      ),
    );
  }
}
