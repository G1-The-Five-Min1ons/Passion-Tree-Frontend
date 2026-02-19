import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';

class NodeItem extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;
  final double size;
  final bool showCurrentIndicator;

  const NodeItem({
    super.key,
    required this.imagePath,
    this.onTap,
    this.size = 64,
    this.showCurrentIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
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
          Image.asset(
            imagePath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}