import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class RetrievePopup extends StatelessWidget{
  const RetrievePopup({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RetrievePopup(),
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
                'Your Reflection Tree is Dead',
                style: AppPixelTypography.smallTitle,
              ),
              const SizedBox(height: 56),
              const Divider(
                color: AppColors.textDisabled,
                thickness: 1,
              ),
              const SizedBox(height: 5),
              Text(
                'Would you like to retrieve?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 48),

              SaveCancel(
                saveText: '5',
                saveIcon: const PixelIcon('assets/icons/Pixel_heart.png'),
                cancelText: 'Cancel',
                onSave: (){
                  Navigator.pop(context);
                  //TODO: add logic
                }, onCancel: () => Navigator.pop(context),
              )
            ],
          )
        ),
      ),
    );
  }
}