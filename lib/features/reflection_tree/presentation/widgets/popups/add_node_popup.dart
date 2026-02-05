import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class AddNodePopup extends StatelessWidget {
  const AddNodePopup({super.key});

  static void show(BuildContext context){
    showDialog(
      context: context,
      builder: (context) => const AddNodePopup()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: [
          PixelBorderContainer(
            pixelSize: 4,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Add Node",
                  style: AppPixelTypography.h3,
                    textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                
                PixelTextField(
                  label: 'Node name : ',
                  hintText: 'Enter Node name',
                  height: 38,
                ),
                const SizedBox(height: 24),

                SaveCancel(
                  onCancel: () {
                    Navigator.pop(context);
                  },
                  onSave: () {
                    //TODO: รอใส่ logic
                  },
                ),
              ], 
            ),
          ),
          Positioned(
            top: 4,
            right: 6,
            child: IconTheme(
              data: const IconThemeData(size: 24),
              child: CloseIcon(
                color: AppColors.textSecondary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      )
    );
  }
}