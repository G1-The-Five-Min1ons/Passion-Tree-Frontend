import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class ResumePopup extends StatelessWidget{
  final VoidCallback? onResume;

  const ResumePopup({super.key, this.onResume});

  static void show(BuildContext context, {VoidCallback? onResume}) {
    showDialog(
      context: context,
      builder: (context) => ResumePopup(onResume: onResume),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 240,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Reflection Tree is Paused',
                style: AppPixelTypography.smallTitle,
              ),
              const SizedBox(height: 56),
              const Divider(
                color: AppColors.textDisabled,
                thickness: 1,
              ),
              const SizedBox(height: 5),
              Text(
                'Would you like to resume?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 48),

              SaveCancel(
                saveText: 'Yes',
                cancelText: 'Cancel',
                onSave: (){
                  Navigator.pop(context);
                  onResume?.call();
                }, onCancel: () => Navigator.pop(context),
              )
            ],
          )
        ),
      ),
    );
  }
}