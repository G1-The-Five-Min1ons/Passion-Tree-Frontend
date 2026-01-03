import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';

class LearningPathOverviewPage extends StatelessWidget {
  const LearningPathOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Learning Paths',
        showBackButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.xmargin,
          right: AppSpacing.xmargin,
          top: AppSpacing.ymargin,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER TITLE =====
            Container(
              height: 72,
              alignment: Alignment.centerLeft,
              child: Text(
                'Learning Paths',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),


            // Header → Search (40)
            const SizedBox(height: 40),

            // ===== SEARCH BAR =====
            Container(
              height: 44,
              color: colors.secondary.withValues(alpha: 0.25),
              alignment: Alignment.centerLeft,
              child: const Text('SEARCH BAR'),
            ),

            // Title → Section (40)
            const SizedBox(height: 40),

            // ===== POPULAR TITLE =====
            Text(
              'Popular\nLearning Paths',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),


            // Title → Content (40)
            const SizedBox(height: 40),

            // ===== POPULAR LIST =====
            Container(
              height: 180,
              color: colors.primary.withValues(alpha: 0.15),
              child: const Center(child: Text('POPULAR LIST')),
            ),

            // Section → Section (60)
            const SizedBox(height: 60),

            // ===== ALL TITLE =====
           Text(
              'All Learning Paths',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),

            // Title → Content (40)
            const SizedBox(height: 40),

            // ===== ALL LIST =====
            Expanded(
              child: Container(
                color: colors.primary.withValues(alpha: 0.15),
                child: const Center(child: Text('ALL LIST')),
              ),
            ),

            // Content → More button (40)
            const SizedBox(height: 40),

            // ===== MORE BUTTON =====
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'More',
                    style: AppPixelTypography.smallTitle.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 5), // ตาม Figma
                  NavigationButton(
                    direction: NavigationDirection.down,
                    onPressed: () {
                      debugPrint('Down pressed');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
