import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';


class CompletionPopup extends StatelessWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;

  const CompletionPopup({super.key, required this.onYes, required this.onNo});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 360,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== HEADER =====
              Text(
                'Congratulations',
                style: AppPixelTypography.title,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'You Have Completed This Learning Path',
                style: AppTypography.subtitleRegular,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // ===== IMAGE PLACEHOLDER =====
              Container(
                height: 140,
                width: 140,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/learning_path/congrats/congrats.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 24),

              const Divider(),

              const SizedBox(height: 16),

              // ===== QUESTION =====
              Text(
                'Would You like to Rate This Learning Path',
                style: AppTypography.subtitleRegular.copyWith(
                  color: colors.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // ===== YES / NO BUTTONS =====
              SaveCancel(
                saveText: 'Yes',
                cancelText: 'No',
                cancelButtonColor: colors.error,
                saveButtonColor: colors.primary,
                onCancel: () {
                  Navigator.pop(context);
                  onNo();
                },
                onSave: () {
                  Navigator.pop(context);
                  onYes();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required VoidCallback onYes,
    required VoidCallback onNo,
  }) {
    showDialog(
      context: context,
      builder: (_) => CompletionPopup(onYes: onYes, onNo: onNo),
    );
  }
}
