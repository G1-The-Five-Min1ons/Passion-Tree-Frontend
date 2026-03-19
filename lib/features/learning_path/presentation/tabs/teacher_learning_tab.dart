
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

  // Cached filtered lists to avoid re-filtering on every build
  List<LearningPath> _filteredAll = [];
  List<EnrolledLearningPath> _filteredEnrolled = [];
  List<LearningPath> _filteredNonEnrolled = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredPaths();
  }

  @override
  void didUpdateWidget(TeacherLearningTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-filter only when data or filter criteria actually change
    if (oldWidget.allPaths != widget.allPaths ||
        oldWidget.enrolledPaths != widget.enrolledPaths ||
        oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.selectedCategory != widget.selectedCategory ||
        oldWidget.ratingRange != widget.ratingRange ||
        oldWidget.maxModules != widget.maxModules) {
      _updateFilteredPaths();
    }
  }

  /// Update all filtered lists
  /// Called only when data or filter criteria change, not on every build
  void _updateFilteredPaths() {
    _filteredAll = _filterCourses(widget.allPaths);
    _filteredEnrolled = _filterEnrolledCourses(widget.enrolledPaths);
    
    // Filter out ALL enrolled paths from "All Learning Paths" and "Recommended"
    final enrolledPathIds = widget.enrolledPaths
        .map((e) => e.pathId)
        .toSet();
    _filteredNonEnrolled = _filteredAll
        .where((path) => !enrolledPathIds.contains(path.id))
        .toList();
  }

  List<LearningPath> _filterCourses(List<LearningPath> courses) {
    return courses.where((c) {
      return _matchesCommonFilters(
        title: c.title,
        description: c.description,
        instructor: c.instructor,
        rating: c.rating,
        modules: c.modules,
      );
    }).toList();
  }

  List<EnrolledLearningPath> _filterEnrolledCourses(List<EnrolledLearningPath> courses) {
    return courses.where((c) {
      return _matchesCommonFilters(
        title: c.title,
        description: c.description,
        instructor: c.instructor,
        rating: c.rating,
        modules: c.modules,
      );
    }).toList();
  }

  bool _matchesCommonFilters({
    required String title,
    required String description,
    required String instructor,
    required double rating,
    required int modules,
  }) {
    final query = widget.searchQuery.trim().toLowerCase();

    final matchesSearch =
        query.isEmpty ||
        title.toLowerCase().contains(query) ||
        description.toLowerCase().contains(query) ||
        instructor.toLowerCase().contains(query);

    final matchesRating =
        widget.ratingRange == null ||
        (rating >= widget.ratingRange!.start &&
            rating <= widget.ratingRange!.end);

    final matchesModules =
        widget.maxModules == null || modules <= widget.maxModules!;

    return matchesSearch && matchesRating && matchesModules;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final filteredEnrolled = _filteredEnrolled;
    final filteredNonEnrolled = _filteredNonEnrolled;
    
    final shownAllCourses = filteredNonEnrolled.take(_allListShownCount).toList();

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
              childAspectRatio: 0.692, // 180/260 สำหรับ progress card
            ),
            itemBuilder: (context, index) {
              return CourseProgressCard(
                data: filteredEnrolled[index],
              );
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
          child: filteredNonEnrolled.isEmpty
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
                  itemCount: filteredNonEnrolled.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return PixelCourseCard(
                      course: filteredNonEnrolled[index],
                    );
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
              return PixelCourseCard(
                course: shownAllCourses[index],
              );
            },
          ),

        // ===== MORE =====
        if (_allListShownCount < filteredNonEnrolled.length) ...[
          const SizedBox(height: 40),
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
        ] else
          const SizedBox(height: 40),
      ],
    );
  }
}

