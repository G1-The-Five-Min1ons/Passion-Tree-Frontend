import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/course_mock.dart';

class LearningPathOverviewPage extends StatefulWidget {
  const LearningPathOverviewPage({super.key});

  @override
  State<LearningPathOverviewPage> createState() =>
      _LearningPathOverviewPageState();
}

class _LearningPathOverviewPageState extends State<LearningPathOverviewPage> {
  String _searchQuery = '';
  int _allListShownCount = 4;

  List<Course> _filterCourses(List<Course> courses) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return courses;
    return courses.where((c) =>
      c.title.toLowerCase().contains(q) ||
      c.description.toLowerCase().contains(q) ||
      c.instructor.toLowerCase().contains(q),
    ).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _allListShownCount = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filteredPopular = _filterCourses(popularCourses);
    final filteredAll = _filterCourses(allCourses);

    // NEW: Limit the number of cards shown in ALL LIST
    final shownAllCourses = filteredAll.take(_allListShownCount).toList();

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Learning Paths',
        showBackButton: false,
        onSearch: (q) => setState(() => _searchQuery = q),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xmargin,
              right: AppSpacing.xmargin,
              top: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                // ===== POPULAR TITLE =====
                Text(
                  'Popular\nLearning Paths',
                  style: AppPixelTypography.title.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 22,
                  ),
                ),

                const SizedBox(height: 16),

                // ===== POPULAR LIST =====
                SizedBox(
                  height: BaseCourseCard.defaultHeight, // 245
                  child: filteredPopular.isEmpty
                      ? Center(
                          child: Text(
                            'No popular paths found',
                            style: AppTypography.subtitleSemiBold.copyWith(
                              color: colors.onPrimary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          itemCount: filteredPopular.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return PixelCourseCard(
                              course: filteredPopular[index],
                            );
                          },
                        ),
                ),

                // Section → Section
                const SizedBox(height: 24),

                // ===== ALL TITLE =====
                Text(
                  'All Learning Paths',
                  style: AppPixelTypography.title.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 22,
                  ),
                ),

                const SizedBox(height: 16),

                // ===== ALL LIST =====
                if (shownAllCourses.isEmpty)
                  Center(
                    child: Text(
                      'No learning paths found',
                      style: AppTypography.subtitleSemiBold.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: shownAllCourses.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 35,
                          crossAxisSpacing: 12,
                          childAspectRatio:
                              BaseCourseCard.defaultWidth /
                              BaseCourseCard.defaultHeight,
                        ),

                    itemBuilder: (context, index) {
                      return PixelCourseCard(course: shownAllCourses[index]);
                    },
                  ),

                // Content → More button (40)
                const SizedBox(height: 40),

                // ===== MORE BUTTON (always visible) =====
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
                          setState(() {
                            _allListShownCount += 4;
                          });
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

