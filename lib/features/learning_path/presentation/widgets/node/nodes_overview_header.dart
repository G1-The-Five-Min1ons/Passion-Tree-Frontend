import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';


class HeaderBar extends StatelessWidget {
  final String title;
  final bool showAddButton;
  final VoidCallback? onPressed; 
  const HeaderBar({
    super.key,
    required this.title,
    this.showAddButton = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xmargin,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== TITLE =====
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(color: colors.onPrimary),
          ),

          /// ===== ADD BUTTON =====
          if (showAddButton)
            Row(
              children: [
                const Spacer(),
                AppButton(
                  variant: AppButtonVariant.iconOnly,
                  icon: const PixelIcon(
                    'assets/icons/Pixel_plus.png',
                    size: 16,
                  ),
                  onPressed: onPressed ?? () {}, // 👈 กัน null
                ),
              ],
            ),
        ],
      ),
    );
  }
}

