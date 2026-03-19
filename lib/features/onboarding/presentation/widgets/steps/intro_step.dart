
import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/login_page.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';


class IntroStep extends StatelessWidget {
  final VoidCallback? onGetStarted;
  const IntroStep({super.key, this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('intro'),
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icons/tree_icon.png', height: 100),
                const SizedBox(height: 30),
                Text("Passion Tree", style: Theme.of(context).textTheme.displayLarge),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: onGetStarted,
          child: PixelBorderContainer(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Get Started',
                style: AppTypography.titleSemiBold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          },
          child: PixelBorderContainer(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            fillColor: Colors.grey.shade100,
            borderColor: Colors.grey.shade300,
            child: Center(
              child: Text(
                'I already have an account',
                style: AppTypography.titleSemiBold.copyWith(color: Colors.grey.shade700),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SizedBox(height: 24),
      ],
    );
  }
}
