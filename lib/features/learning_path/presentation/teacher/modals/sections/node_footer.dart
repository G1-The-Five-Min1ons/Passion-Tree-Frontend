import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';

class NodeFooter extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onSave;

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
            backgroundColor: colors.error, 
            textColor: colors.onError,
            onPressed: onDelete,
          ),

          const SizedBox(width: 16),

          // ===== SAVE =====
          AppButton(
            variant: AppButtonVariant.text,
            text: 'Save',
            backgroundColor: colors.primary,
            textColor: colors.onPrimary,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}
