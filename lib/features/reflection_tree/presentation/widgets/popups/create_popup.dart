import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';

class CreatePopUp extends StatelessWidget {
  final String title;
  final String hint;

  const CreatePopUp({
    super.key,
    required this.title,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: PixelBorderContainer(
        pixelSize: 4,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 18),

            GestureDetector(
              onTap: () {
                //TODO: รอใส่ logic
              },
              child: PixelBorderContainer(
                  pixelSize: 2,
                  width: double.infinity,
                  height: 150,
                  padding: EdgeInsets.zero,
                  borderColor: AppColors.scale,
                  fillColor: AppColors.scale,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload Cover Image',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
            ),

            const SizedBox(height: 18),

            const PixelTextField(
              hintText: 'Album Name',
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
    );
  }
  static void show(
    BuildContext context, {
    String title = 'Create Album',
    String hint = 'Album Name',
  }) {
    showDialog(
      context: context,
      builder: (context) => CreatePopUp(
        title: title,
        hint: hint,
      ),
    );
  }
}