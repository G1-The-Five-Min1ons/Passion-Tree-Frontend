import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_state.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';

class BottomBar extends StatelessWidget {
  final VoidCallback onSaveDraft;
  final VoidCallback onPublish;

  const BottomBar({
    super.key,
    required this.onSaveDraft,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              variant: AppButtonVariant.text,
              text: 'Save Draft',
              backgroundColor: AppColors.scale,
              textColor: AppColors.textPrimary,
              onPressed: onSaveDraft,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              variant: AppButtonVariant.text,
              text: 'Publish',
              onPressed: onPublish,
            ),
          ),
        ],
      ),
    );
  }
}

