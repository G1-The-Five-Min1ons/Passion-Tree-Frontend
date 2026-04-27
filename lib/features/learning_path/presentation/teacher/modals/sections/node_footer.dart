import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class NodeFooter extends StatelessWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onSave;

  const NodeFooter({super.key, required this.onDelete, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // ===== DELETE =====
          AppButton(
            variant: AppButtonVariant.text,
            text: 'Delete',
            backgroundColor: onDelete == null ? AppColors.scale : colors.error,
            textColor: onDelete == null ? AppColors.textDisabled : colors.onError,
            onPressed: onDelete,
          ),

          const SizedBox(width: 16),

          // ===== SAVE =====
          AppButton(
            variant: AppButtonVariant.text,
            text: 'Save',
            backgroundColor: onSave == null ? AppColors.scale : colors.primary,
            textColor: onSave == null ? AppColors.textDisabled : colors.onPrimary,
            disabledOpacity: 0.75,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}
