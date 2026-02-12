import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class ConfirmPopup extends StatelessWidget {
  final String title;
  final String body;
  final String confirmText;
  final Color? confirmColor;
  final VoidCallback onConfirm;

  const ConfirmPopup({
    super.key,
    required this.title,
    required this.body,
    required this.onConfirm,
    this.confirmText = 'Confirm',
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 315,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== TITLE =====
              Text(
                title,
                style: AppPixelTypography.title,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // ===== BODY =====
              Text(
                body,
                style: AppTypography.subtitleRegular,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 26),

              // ===== ACTION BUTTONS =====
              SaveCancel(
                saveText: confirmText,
                saveButtonColor: confirmColor,
                cancelText: 'Cancel',
                onCancel: () => Navigator.pop(context),
                onSave: () {
                  Navigator.pop(context);
                  onConfirm();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== STATIC HELPER =====
  static void show(
    BuildContext context, {
    required String title,
    required String body,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    Color? confirmColor,
  }) {
    showDialog(
      context: context,
      builder: (_) => ConfirmPopup(
        title: title,
        body: body,
        onConfirm: onConfirm,
        confirmText: confirmText,
        confirmColor: confirmColor,
      ),
    );
  }
}
