import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/course_mock.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';


class TeacherLearningTab extends StatefulWidget {
  final String searchQuery;
  final String? selectedCategory;
  final RangeValues? ratingRange;
  final int? maxModules;

  /// callback ให้ Page จัดการเปิด Status content
  final VoidCallback onOpenStatus;

  const TeacherLearningTab({
    super.key,
    required this.searchQuery,
    this.selectedCategory,
    this.ratingRange,
    this.maxModules,
    required this.onOpenStatus,
  });

  @override
  State<TeacherLearningTab> createState() => _TeacherLearningTabState();
}

class _TeacherLearningTabState extends State<TeacherLearningTab> {
  int _allListShownCount = 4;

  List<Course> _filterCourses(List<Course> courses) {
    return courses.where((c) {
      final query = widget.searchQuery.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          c.title.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query) ||
          c.instructor.toLowerCase().contains(query);

      final matchesCategory =
          widget.selectedCategory == null ||
          c.category == widget.selectedCategory;

      final matchesRating =
          widget.ratingRange == null ||
          (c.rating >= widget.ratingRange!.start &&
              c.rating <= widget.ratingRange!.end);

      final matchesModules =
          widget.maxModules == null || c.modules <= widget.maxModules!;

      return matchesSearch &&
          matchesCategory &&
          matchesRating &&
          matchesModules;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final filteredPopular = _filterCourses(popularCourses);
    final filteredAll = _filterCourses(allCourses);
    final shownAllCourses = filteredAll.take(_allListShownCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== TITLE + STATUS BUTTON =====
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Learning Paths',
              style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
            ),
            SizedBox(
              width: 18,
              height: 30,
              child: NavigationButton(
                direction: NavigationDirection.right,
                onPressed: widget.onOpenStatus, // ✅ ให้ Page จัดการ
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // ===== MY LEARNING PATHS =====
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredPopular.length < 2 ? filteredPopular.length : 2,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 35,
            crossAxisSpacing: 12,
            childAspectRatio:
                PixelCourseCard.cardWidth / PixelCourseCard.cardHeight,
          ),
          itemBuilder: (context, index) {
            return PixelCourseCard(course: filteredPopular[index]);
          },
        ),

        // ===== RECOMMENDED =====
        const SizedBox(height: 60),
        Text(
          'Recommended for you',
          style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
        ),
        const SizedBox(height: 40),

        SizedBox(
          height: PixelCourseCard.cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filteredPopular.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return PixelCourseCard(course: filteredPopular[index]);
            },
          ),
        ),

        // ===== ALL LEARNING PATHS =====
        const SizedBox(height: 60),
        Text(
          'All Learning Paths',
          style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
        ),
        const SizedBox(height: 40),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shownAllCourses.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 35,
            crossAxisSpacing: 12,
            childAspectRatio:
                PixelCourseCard.cardWidth / PixelCourseCard.cardHeight,
          ),
          itemBuilder: (context, index) {
            return PixelCourseCard(course: shownAllCourses[index]);
          },
        ),

        const SizedBox(height: 40),

        // ===== MORE =====
        Center(
          child: NavigationButton(
            direction: NavigationDirection.down,
            onPressed: () {
              setState(() {
                _allListShownCount += 4;
              });
            },
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

