import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

enum OAuthProvider { google, discord }

class OAuthButton extends StatelessWidget {
  final OAuthProvider provider;
  final VoidCallback onPressed;
  final double height;
  final double? width;

  const OAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.height = 48.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(
            color: colorScheme.onSurface,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
          children: [
            // Icon
            Image.asset(
              _getIconPath(),
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            // Text
            Text(
              _getButtonText(),
              style: AppTypography.subtitleSemiBold.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getIconPath() {
    switch (provider) {
      case OAuthProvider.google:
        return 'assets/icons/google.png';
      case OAuthProvider.discord:
        return 'assets/icons/discord.png';
    }
  }

  String _getButtonText() {
    switch (provider) {
      case OAuthProvider.google:
        return 'Google';
      case OAuthProvider.discord:
        return 'Discord';
    }
  }
}
