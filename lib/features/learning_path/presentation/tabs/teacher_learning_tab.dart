
import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_progress_card.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';


class TeacherLearningTab extends StatefulWidget {
  final List<LearningPath> allPaths;
  final List<EnrolledLearningPath> enrolledPaths;
  final String searchQuery;
  final String? selectedCategory;
  final RangeValues? ratingRange;
  final int? maxModules;

  /// callback ให้ Page จัดการเปิด Status content
  final VoidCallback onOpenStatus;

  const TeacherLearningTab({
    super.key,
    required this.allPaths,
    required this.enrolledPaths,
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

  List<LearningPath> _filterCourses(List<LearningPath> courses) {
    return courses.where((c) {
      final query = widget.searchQuery.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          c.title.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query) ||
          c.instructor.toLowerCase().contains(query);

      final matchesRating =
          widget.ratingRange == null ||
          (c.rating >= widget.ratingRange!.start &&
              c.rating <= widget.ratingRange!.end);

      final matchesModules =
          widget.maxModules == null || c.modules <= widget.maxModules!;

      return matchesSearch && matchesRating && matchesModules;
    }).toList();
  }

  List<EnrolledLearningPath> _filterEnrolledCourses(List<EnrolledLearningPath> courses) {
    return courses.where((c) {
      final query = widget.searchQuery.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          c.title.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query) ||
          c.instructor.toLowerCase().contains(query);

      final matchesRating =
          widget.ratingRange == null ||
          (c.rating >= widget.ratingRange!.start &&
              c.rating <= widget.ratingRange!.end);

      final matchesModules =
          widget.maxModules == null || c.modules <= widget.maxModules!;

      return matchesSearch && matchesRating && matchesModules;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final filteredAll = _filterCourses(widget.allPaths);
    final filteredEnrolled = _filterEnrolledCourses(widget.enrolledPaths);
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
                onPressed: widget.onOpenStatus, // ให้ Page จัดการ
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // ===== MY LEARNING PATHS =====
        if (filteredEnrolled.isEmpty)
          Center(
            child: Text(
              'No enrolled paths found',
              style: AppTypography.subtitleSemiBold.copyWith(
                color: colors.onPrimary,
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredEnrolled.length < 2 ? filteredEnrolled.length : 2,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 35,
              crossAxisSpacing: 12,
              childAspectRatio:
                  BaseCourseCard.defaultWidth / BaseCourseCard.defaultHeight,
            ),
            itemBuilder: (context, index) {
              return CourseProgressCard(data: filteredEnrolled[index]);
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
          height: BaseCourseCard.defaultHeight,
          child: filteredAll.isEmpty
              ? Center(
                  child: Text(
                    'No recommended paths found',
                    style: AppTypography.subtitleSemiBold.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredAll.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return PixelCourseCard(course: filteredAll[index]);
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 35,
              crossAxisSpacing: 12,
              childAspectRatio:
                  BaseCourseCard.defaultWidth / BaseCourseCard.defaultHeight,
            ),
            itemBuilder: (context, index) {
              return PixelCourseCard(course: shownAllCourses[index]);
            },
          ),

        const SizedBox(height: 40),

        // ===== MORE =====
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

        const SizedBox(height: 40),
      ],
    );
  }
}

