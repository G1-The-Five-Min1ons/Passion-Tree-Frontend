import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';

class BottomBar extends StatelessWidget {
  final VoidCallback onSaveDraft;
  final VoidCallback onPublish;
  final bool isPublished;

  const BottomBar({
    super.key,
    required this.onSaveDraft,
    required this.onPublish,
    this.isPublished = false,
  });

  @override
  Widget build(BuildContext context) {
    // ถ้า published แล้ว ไม่แสดงปุ่มเลย
    if (isPublished) {
      return const SizedBox.shrink();
    }

    
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: SizedBox(
          width: double.infinity,
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
                  backgroundColor: AppColors.submit,
                  textColor: AppColors.textPrimary,
                  onPressed: onPublish,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
