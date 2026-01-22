import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final IconData actionIcon;
  final VoidCallback onActionPressed;

  const PageHeader({
    super.key,
    required this.title,
    required this.actionIcon,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
         Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              variant: AppButtonVariant.iconOnly,
              icon: const PixelIcon('assets/icons/Pixel_plus.png', size: 16),
              onPressed: onActionPressed,
            ),
          ],
        ), 
      ],
    );
  }
}