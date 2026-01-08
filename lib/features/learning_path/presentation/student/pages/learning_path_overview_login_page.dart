import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/search_bar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/filter_section.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/course_mock.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_status_page.dart';

class LearningPathOverviewLoginPage extends StatefulWidget {
  const LearningPathOverviewLoginPage({super.key});

  @override
  State<LearningPathOverviewLoginPage> createState() =>
      _LearningPathOverviewLoginPageState();
}

class _LearningPathOverviewLoginPageState extends State<LearningPathOverviewLoginPage> {
  final TextEditingController _searchController = TextEditingController();

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
                // ===== HEADER TITLE + NavigationButton =====
                SizedBox(
                  height: 72,
                  child: Row(
                    children: [
                      Expanded(
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
                      // NavigationButton (left) at right side
                      NavigationButton(
                        direction: NavigationDirection.left,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
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

                // ===== My Learning Paths Titles + navigation button =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Learning Paths',
                      style: AppPixelTypography.title.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(
                      width: 18,
                      height: 30,
                      child: NavigationButton(
                        direction: NavigationDirection.right,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LearningPathStatusPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Title → Content (40)
                const SizedBox(height: 40),

                // ===== MY LEARNING PATHS LIST (fixed 2 cards, grid) =====
                if (filteredPopular.isEmpty)
                  Center(
                    child: Text(
                      'No popular paths found',
                      style: AppTypography.subtitleSemiBold.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredPopular.length < 2 ? filteredPopular.length : 2,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 35,
                      crossAxisSpacing: 12,
                      childAspectRatio: PixelCourseCard.cardWidth / PixelCourseCard.cardHeight,
                    ),
                    itemBuilder: (context, index) {
                      return PixelCourseCard(course: filteredPopular[index]);
                    },
                  ),

                // ===== RECOMMENDED FOR YOU SECTION =====
                const SizedBox(height: 60),
                Text(
                  'Recommended for you',
                  style: AppPixelTypography.title.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: PixelCourseCard.cardHeight,
                  child: filteredPopular.isEmpty // ใช้ filteredPopular เป็น mock data
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
                // ===== END RECOMMENDED FOR YOU SECTION =====

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
                          crossAxisCount: 2, // 2 การ์ดต่อแถว
                          mainAxisSpacing: 35, // ระยะห่างแนวตั้ง
                          crossAxisSpacing: 12, // ระยะห่างแนวนอน
                          childAspectRatio:
                              PixelCourseCard.cardWidth /
                              PixelCourseCard.cardHeight,
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
