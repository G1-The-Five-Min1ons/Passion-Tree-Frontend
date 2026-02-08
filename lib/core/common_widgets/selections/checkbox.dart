import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class PixelCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final double size;
  final Color? activeColor;
  final Color? borderColor;

  const PixelCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 18.0,
    this.activeColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeCheckColor = activeColor ?? colorScheme.primary;
    final activeBorderColor = borderColor ?? AppColors.scale;

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(
            color: activeBorderColor,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(3), 
        child: value
            ? Container(
                decoration: BoxDecoration(
                  color: activeCheckColor,
                ),
              )
            : null
      ),
    );
  }
}

