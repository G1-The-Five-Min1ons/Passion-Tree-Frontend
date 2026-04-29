import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class NodeItem extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;
  final double size;
  final bool showCurrentIndicator;
  final String? title;

  const NodeItem({
    super.key,
    required this.imagePath,
    this.onTap,
    this.size = 64,
    this.showCurrentIndicator = false,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final hasTitle = title != null && title!.trim().isNotEmpty;

    final nodeWithSideTitle = Stack(
      clipBehavior: Clip.none,
      children: [
        Image.asset(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        ),
        if (hasTitle)
          Positioned(
            left: size + 8,
            top: (size / 2) - 12,
            child: SizedBox(
              width: 160,
              child: Text(
                title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppTypography.h3SemiBold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show down arrow indicator if this is the current learning node
          if (showCurrentIndicator) ...[
            NavigationButton(
              direction: NavigationDirection.down,
              onPressed: () {
                // This is just an indicator, so we can call onTap or do nothing
                if (onTap != null) {
                  onTap!();
                }
              },
            ),
            const SizedBox(height: 4),
          ],
          nodeWithSideTitle,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
