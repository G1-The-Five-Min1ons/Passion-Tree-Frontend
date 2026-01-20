import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';

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
      child: Center(
       
        child: SizedBox(
          width: 320, // 👈 ความกว้างรวมของปุ่ม (ปรับได้)
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
        ),
      ),
    );
  }
}
