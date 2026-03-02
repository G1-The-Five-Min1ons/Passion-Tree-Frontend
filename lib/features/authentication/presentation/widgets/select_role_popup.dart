import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class SelectRolePopup extends StatelessWidget {
  final Function(String) onRoleSelected;

  const SelectRolePopup({super.key, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      child: PixelBorderContainer(
        pixelSize: 4,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppPixelTypography.h3.copyWith(
                  color: colorScheme.onSurface,
                ),
                children: [
                  const TextSpan(text: 'Please select your '),
                  TextSpan(
                    text: 'role',
                    style: TextStyle(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            AppButton(
              variant: AppButtonVariant.text,
              text: ' Student ',
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
              onPressed: () => onRoleSelected('student'),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'or',
                style: AppPixelTypography.title.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            AppButton(
              variant: AppButtonVariant.text,
              text: ' Teacher ',
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
              onPressed: () => onRoleSelected('teacher'),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}