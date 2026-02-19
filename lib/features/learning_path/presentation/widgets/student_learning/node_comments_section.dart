import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';

//วางlayoutไว้ก่อน
class NodeCommentsSection extends StatelessWidget {
  const NodeCommentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PixelBorderContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderColor: colors.primary,
      fillColor: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== TITLE =====
          Text(
            'Comments',
            style: Theme.of(
              context,
            ).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          // ===== PLACEHOLDER CONTENT =====
          Text(
            'Comment list will be displayed here in sprint 3.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurface),
          ),
        ],
      ),
    );
  }
}
