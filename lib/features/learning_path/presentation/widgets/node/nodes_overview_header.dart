import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xmargin,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biology 101',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              AppButton(
                variant: AppButtonVariant.iconOnly,
                icon: const PixelIcon(
                  'assets/icons/Pixel_plus.png',
                  size: 16,
                ),
                onPressed: () {
                  // create node
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

