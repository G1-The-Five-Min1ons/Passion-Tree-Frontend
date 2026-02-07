import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class BottomButtons extends StatelessWidget {
  final VoidCallback onGoogleTap;
  final VoidCallback onDiscordTap;

  const BottomButtons({
    super.key,
    required this.onGoogleTap,
    required this.onDiscordTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        AppButton(
          variant: AppButtonVariant.leadingIconWithText,
          backgroundColor: AppColors.surface,
          textColor: colorScheme.onSurface,
          text: 'Google',
          icon: Image.asset(
            'assets/icons/google.png',
            width: 18,
            height: 18,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.g_mobiledata, size: 16),
          ),
          onPressed: onGoogleTap,
        ),

        AppButton(
          variant: AppButtonVariant.leadingIconWithText,
          backgroundColor: AppColors.surface,
          textColor: colorScheme.onSurface,
          text: 'Discord',
          icon: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/icons/discord.jpg',
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.discord, size: 16),
            ),
          ),
          onPressed: onDiscordTap,
        ),
      ],
    );
  }
}