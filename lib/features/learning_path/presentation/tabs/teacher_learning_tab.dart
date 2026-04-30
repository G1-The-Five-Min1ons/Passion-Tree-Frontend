import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_progress_card.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/arrow_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
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


  // Cached filtered lists to avoid re-filtering on every build
  List<LearningPath> _filteredAll = [];
  List<EnrolledLearningPath> _filteredEnrolled = [];

  int _gridCrossAxisCount(double width) {
    if (width < 420) return 1;
    if (width < 760) return 2;
    if (width < 1100) return 3;
    return 4;
  }

  @override
  void initState() {
    super.initState();
    _updateFilteredPaths();
  }

  @override
  void dispose() {
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
    final size = MediaQuery.sizeOf(context);
    final enrolledCrossAxisCount = _gridCrossAxisCount(size.width);
    final allCrossAxisCount = _gridCrossAxisCount(size.width);

    final filteredEnrolled = _filteredEnrolled;
    final filteredAll = _filteredAll;

    // Exclude enrolled paths from all paths display
    final enrolledPathIds = _filteredEnrolled
        .map((e) => e.pathId.trim())
        .toSet();
    final filteredRecommended = filteredAll
        .where((path) => !enrolledPathIds.contains(path.id.trim()))
        .toList();

    final shownAllCourses = filteredRecommended.take(_allListShownCount).toList();

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
            itemCount: filteredEnrolled.length.clamp(0, 4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: allCrossAxisCount,
              mainAxisSpacing: 35,
              crossAxisSpacing: 12,
              childAspectRatio:
                  BaseCourseCard.defaultWidth / BaseCourseCard.defaultHeight,
            ),
            itemBuilder: (context, index) {
              return PixelCourseCard(course: shownAllCourses[index]);
            },
          ),
        if (filteredRecommended.length > _allListShownCount) ...[
          const SizedBox(height: 32),
          Center(
            child: AppButton(
              variant: AppButtonVariant.text,
              text: 'View All',
              icon: Icon(Icons.arrow_forward, size: 20, color: colors.onPrimary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllLearningPathsPage(paths: filteredRecommended),
                  ),
                );
              },
              textColor: colors.onPrimary,
            ),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}
