import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_state.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ===== HEADER =====
          SizedBox(
            height: 120, // เพิ่มความสูงเพื่อรองรับ subtitle
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Biology 101',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

              ],
            ),
          ),

         // ===== Add button (top right) =====
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              variant: AppButtonVariant.iconOnly,
              icon: const PixelIcon('assets/icons/Pixel_plus.png', size: 16),
              onPressed: () {
                // กดแล้วมีให้create nodeเพิ่ม
              },
            ),
          ),
        ],
      ),
    );
  }
}
