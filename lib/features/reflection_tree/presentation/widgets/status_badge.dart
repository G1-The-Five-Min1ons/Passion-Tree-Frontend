import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class StatusBadge extends StatelessWidget{
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
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

    final Color effectiveColor = statusColors[currentStatus] ?? AppColors.status;

    return Align(
      alignment: Alignment.center,
      child: PixelBorderContainer(
      width: 105,
      pixelSize: 3,
      borderColor: effectiveColor,
      fillColor: effectiveColor,
      padding: const EdgeInsets.symmetric(vertical:6),
      child: Center(
        child: Text(
            currentStatus,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary ),
          ),
        ),
      ),
    );
  }
}