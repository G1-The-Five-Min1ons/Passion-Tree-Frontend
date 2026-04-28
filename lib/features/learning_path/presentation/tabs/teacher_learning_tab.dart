import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_progress_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/recommendation_card.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/arrow_button.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/all_learning_paths_page.dart';

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
  late final PageController _recommendationPageController;
  int _recommendationPage = 0;

  // Cached filtered lists to avoid re-filtering on every build
  List<LearningPath> _filteredAll = [];
  List<EnrolledLearningPath> _filteredEnrolled = [];
  List<LearningPath> _filteredNonEnrolled = [];

  @override
  void initState() {
    super.initState();
    _recommendationPageController = PageController(viewportFraction: 1.0);
    _updateFilteredPaths();
  }

  @override
  void dispose() {
    _recommendationPageController.dispose();
    super.dispose();
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
    final enrolledPathIds = widget.enrolledPaths.map((e) => e.pathId).toSet();
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

  List<EnrolledLearningPath> _filterEnrolledCourses(
    List<EnrolledLearningPath> courses,
  ) {
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
    final filteredAll = _filteredAll;
    final filteredNonEnrolled = _filteredNonEnrolled;

    final shownAllCourses = filteredAll.take(_allListShownCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.onOpenStatus,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Learning Paths',
                style: AppPixelTypography.title.copyWith(
                  color: colors.onPrimary,
                ),
              ),
              ArrowButton(
                direction: ArrowDirection.right,
                onPressed: widget.onOpenStatus,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
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
            itemCount: filteredEnrolled.length < 2
                ? filteredEnrolled.length
                : 2,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 35,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (context, index) {
              return CourseProgressCard(data: filteredEnrolled[index]);
            },
          ),
        const SizedBox(height: 60),
        Text(
          'Recommendation',
          style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
        ),
        const SizedBox(height: 8),
        if (filteredNonEnrolled.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.swipe_right_alt,
                size: 18,
                color: colors.onPrimary.withValues(alpha: 0.72),
              ),
              const SizedBox(width: 6),
              Text(
                'Swipe right to see more recommendations',
                style: AppTypography.smallBodyMedium.copyWith(
                  color: colors.onPrimary.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        const SizedBox(height: 18),
        SizedBox(
          height: 310,
          child: filteredNonEnrolled.isEmpty
              ? Center(
                  child: Text(
                    'No recommended paths found',
                    style: AppTypography.subtitleSemiBold.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                )
              : PageView.builder(
                  controller: _recommendationPageController,
                  onPageChanged: (page) {
                    setState(() => _recommendationPage = page);
                  },
                  itemCount: filteredNonEnrolled.length,
                  itemBuilder: (context, index) {
                    return RecommendationCard(
                      course: filteredNonEnrolled[index],
                    );
                  },
                ),
        ),
        if (filteredNonEnrolled.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              filteredNonEnrolled.length.clamp(0, 7),
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: _recommendationPage == i ? 14 : 7,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _recommendationPage == i
                      ? colors.primary
                      : colors.onPrimary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 60),
        Text(
          'All Learning Paths',
          style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
        ),
        const SizedBox(height: 18),
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
        if (filteredAll.length > _allListShownCount) ...[
          const SizedBox(height: 32),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllLearningPathsPage(paths: filteredAll),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.cardBorder, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: AppTypography.subtitleSemiBold.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.arrow_forward, size: 20, color: colors.onPrimary),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}
