import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class StatusBadge extends StatelessWidget{
  final String status;
  final String? label;
  final Color? badgeColor;
  final Color? labelColor;
  final double width;
  final double horizontalPadding;

  const StatusBadge({
    super.key,
    required this.status,
    this.label,
    this.badgeColor,
    this.labelColor,
    this.width = 105,
    this.horizontalPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.trim().toLowerCase();

    final Map<String, String> statusAliases = {
      'active': 'growing',
    };

    final currentStatus =
        statusAliases[normalizedStatus] ??
        (normalizedStatus.isEmpty ? 'growing' : normalizedStatus);

    final Map<String, Color> statusColors = {
      'growing' : AppColors.status,
      'fading' : AppColors.warning,
      'dying' : AppColors.cancel,
      'died' : AppColors.died,
    };

    final String effectiveLabel = (label ?? currentStatus).trim();
    final Color effectiveColor = badgeColor ?? (statusColors[currentStatus] ?? AppColors.status);

    return Align(
      alignment: Alignment.center,
      child: PixelBorderContainer(
      width: width,
      pixelSize: 3,
      borderColor: effectiveColor,
      fillColor: effectiveColor,
      padding: EdgeInsets.symmetric(
        vertical: 6,
        horizontal: horizontalPadding,
      ),
      child: Center(
        child: Text(
            effectiveLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: labelColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}