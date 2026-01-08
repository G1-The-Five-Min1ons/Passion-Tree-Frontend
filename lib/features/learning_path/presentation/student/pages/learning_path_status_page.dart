import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/search_bar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/filter_section.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/course_mock.dart';


class LearningPathStatusPage extends StatefulWidget {
  const LearningPathStatusPage({super.key});

  @override
  State<LearningPathStatusPage> createState() => _LearningPathStatusPageState();
}

class _LearningPathStatusPageState extends State<LearningPathStatusPage> {
  final TextEditingController _searchController = TextEditingController();
  
  //status
  int inProgressShown = 2;
  int completedShown = 2;

  // Filter state
  String? _selectedCategory;
  RangeValues? _ratingRange;
  int? _maxModules;

  // === NEW: State for controlling number of shown cards ===
  int _allListShownCount = 4;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Course> _filterCourses(List<Course> courses) {
    return courses.where((Course c) {
      // Search query filter
      final query = _searchController.text.trim().toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          c.title.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query) ||
          c.instructor.toLowerCase().contains(query);

      // Category filter
      final matchesCategory =
          _selectedCategory == null || c.category == _selectedCategory;

      // Rating filter (range)
      final matchesRating =
          _ratingRange == null ||
          (c.rating >= _ratingRange!.start && c.rating <= _ratingRange!.end);

      // Modules filter
      final matchesModules = _maxModules == null || c.modules <= _maxModules!;

      return matchesSearch &&
          matchesCategory &&
          matchesRating &&
          matchesModules;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _ratingRange = null;
      _maxModules = null;
      // NEW: Reset shown count when filters are cleared
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

    final inProgressCourses = mockCourses
        .where((c) => c.status == CourseStatus.inProgress)
        .toList();

    final completedCourses = mockCourses
        .where((c) => c.status == CourseStatus.completed)
        .toList();

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
                // ===== HEADER TITLE (removed NavigationButton left/right) =====
                SizedBox(
                  height: 72,
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Learning Paths',
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                          ),
                        ),
                      ),
                      // NavigationButton removed
                    ],
                  ),
                ),

                // Header → Search (40)
                const SizedBox(height: 40),

                // ===== SEARCH BAR & FILTER =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: LearningPathSearchBar(
                          controller: _searchController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilterSection(
                        selectedCategory: _selectedCategory,
                        ratingRange: _ratingRange,
                        maxModules: _maxModules,
                        onFiltersChanged: (category, rating, modules) {
                          setState(() {
                            _selectedCategory = category;
                            _ratingRange = rating;
                            _maxModules = modules;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Title → Section (40)
                const SizedBox(height: 40),

                // ===== My Learning Paths Titles in progress  =====
                Text(
                  'My Learning Paths',
                  style: AppPixelTypography.title.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

                const SizedBox(height: 20),

                // ===== My Learning Paths (In progress) =====
                RichText(
                  text: TextSpan(
                    style: AppPixelTypography.smallTitle.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    children: [
                      const TextSpan(text: 'Status : '),
                      TextSpan(
                        text: 'In progress',
                        style: AppPixelTypography.smallTitle.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                if (inProgressCourses.isEmpty)
                  Center(
                    child: Text(
                      'No in-progress paths found',
                      style: AppTypography.subtitleSemiBold.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: inProgressCourses.length < inProgressShown
                        ? inProgressCourses.length
                        : inProgressShown,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 35,
                          crossAxisSpacing: 12,
                          childAspectRatio:
                              PixelCourseCard.cardWidth /
                              PixelCourseCard.cardHeight,
                        ),
                    itemBuilder: (context, index) {
                      return PixelCourseCard(course: inProgressCourses[index]);
                    },
                  ),

                if (inProgressShown < inProgressCourses.length)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: NavigationButton(
                        direction: NavigationDirection.down,
                        onPressed: () {
                          setState(() {
                            inProgressShown += 2;
                          });
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 60),
                
                // ===== My Learning Paths Titles Completed=====
                Text(
                  'My Learning Paths',
                  style: AppPixelTypography.title.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

                const SizedBox(height: 20),

                // ===== My Learning Paths (Completed) =====
                RichText(
                  text: TextSpan(
                    style: AppPixelTypography.smallTitle.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    children: const [
                      TextSpan(text: 'Status : '),
                      TextSpan(
                        text: 'Completed',
                        style: TextStyle(color: AppColors.status),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                if (completedCourses.isEmpty)
                  Center(
                    child: Text(
                      'No completed paths found',
                      style: AppTypography.subtitleSemiBold.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: completedCourses.length < completedShown
                        ? completedCourses.length
                        : completedShown,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 35,
                          crossAxisSpacing: 12,
                          childAspectRatio:
                              PixelCourseCard.cardWidth /
                              PixelCourseCard.cardHeight,
                        ),
                    itemBuilder: (context, index) {
                      return PixelCourseCard(course: completedCourses[index]);
                    },
                  ),

                if (completedShown < completedCourses.length)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: NavigationButton(
                        direction: NavigationDirection.down,
                        onPressed: () {
                          setState(() {
                            completedShown += 2;
                          });
                        },
                      ),
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
