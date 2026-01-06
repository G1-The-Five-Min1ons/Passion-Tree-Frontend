import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/course_mock.dart';

class LearningPathOverviewPage extends StatelessWidget {
  const LearningPathOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xmargin,
              right: AppSpacing.xmargin,
              top: AppSpacing.ymargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== HEADER TITLE =====
                SizedBox(
                  height: 72,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Learning Paths',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),

                // Header → Search (40)
                const SizedBox(height: 40),

                // ===== SEARCH BAR =====
                Container(
                  height: 44,
                  width: double.infinity,
                  color: colors.secondary.withValues(alpha: 0.25),
                  alignment: Alignment.centerLeft,
                  child: const Text('SEARCH BAR'),
                ),

                // Title → Section (40)
                const SizedBox(height: 40),

                // ===== POPULAR TITLE =====
                Text(
                  'Popular\nLearning Paths',
                  style: AppPixelTypography.title.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

                // Title → Content (40)
                const SizedBox(height: 40),

                // ===== POPULAR LIST =====
                SizedBox(
                  height: PixelCourseCard.cardHeight, // 245
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    itemCount: popularCourses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return PixelCourseCard(course: popularCourses[index]);
                    },
                  ),
                ),

                // Section → Section (60)
                const SizedBox(height: 60),

                // ===== ALL TITLE =====
                Text(
                  'All Learning Paths',
                  style: AppPixelTypography.title.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

                // Title → Content (40)
                const SizedBox(height: 40),

                // ===== ALL LIST =====
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allCourses.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 การ์ดต่อแถว
                    mainAxisSpacing: 35, // ระยะห่างแนวตั้ง
                    crossAxisSpacing: 12, // ระยะห่างแนวนอน
                    childAspectRatio:
                        PixelCourseCard.cardWidth / PixelCourseCard.cardHeight,
                  ),
                    itemBuilder: (context, index) {
                      return PixelCourseCard(course: allCourses[index]);
                  },
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
                      const SizedBox(height: 5),
                      NavigationButton(
                        direction: NavigationDirection.down,
                        onPressed: () {
                          debugPrint('Down pressed');
                        },
                      ),
                    ],
                  ),
                ),

                // bottom safe spacing
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

