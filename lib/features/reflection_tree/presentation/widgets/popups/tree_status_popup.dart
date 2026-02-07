import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/select_pause_period.dart';

class TreeStatusPopup extends StatelessWidget {
  final String status;

  const TreeStatusPopup({super.key, required this.status});

  static void show(BuildContext context, String status) {
    showDialog(
      context: context,
      builder: (context) => TreeStatusPopup(status: status),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = "";
    String description = "";
    Color color = Colors.white;

    switch (status) {
      case 'growing':
        title = "Excellent";
        description = "Your Reflection Tree is Growing";
        color = AppColors.status;
        break;
      case 'fading':
        title = "Warning";
        description = "Your Reflection Tree is Fading.";
        color = AppColors.warning;
        break;
      case 'dying':
        title = "Warning";
        description = "Your Reflection Tree is Dying.";
        color = AppColors.cancel;
        break;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 240,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.all(24),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(title, style: AppPixelTypography.smallTitle.copyWith(color: color)),
                  const SizedBox(height: 5),
                  Text(description, style: AppTypography.subtitleRegular),
                  const SizedBox(height: 48),

                  const Divider(
                    color: AppColors.textDisabled,
                    thickness: 1,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Would you like to pause?", style: AppTypography.titleSemiBold
                  ),

                  const SizedBox(height: 48),

                  SaveCancel(
                  saveText: 'Yes',
                  cancelText: 'Cancel',
                  onCancel: () => Navigator.pop(context),
                  onSave: () {
                    Navigator.pop(context);
                    SelectPausePeriodPopup.show(context);
                  },
                ),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}