import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_progress_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/search_bar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/filter_section.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_status_page.dart';

class LearningPathOverviewPage extends StatefulWidget {
  const LearningPathOverviewPage({super.key});

  @override
  State<LearningPathOverviewPage> createState() =>
      _LearningPathOverviewPageState();
}

class _LearningPathOverviewPageState extends State<LearningPathOverviewPage> {
  final TextEditingController _searchController = TextEditingController();

  // Filter state
  String? _selectedCategory;
  RangeValues? _ratingRange;
  int? _maxModules;

  // === NEW: State for controlling number of shown cards ===
  int _allListShownCount = 4;

  static const String? mockUserId = "a33282ca-e6f1-4fbf-9f51-fab7ffba3bfc"; // Set to null if not logged in

  // Cache overview data
  LearningPathOverviewLoaded? _cachedOverview;

  @override
  void initState() {
    super.initState();
    
    debugPrint('[UI] LearningPathOverviewPage - initState');
    debugPrint('Mock User ID: $mockUserId');
    
    // Fetch overview data from backend
    context.read<LearningPathBloc>().add(
      FetchLearningPathOverview(userId: mockUserId),
    );
    
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
 
  List<LearningPath> _filterCourses(List<LearningPath> courses) {
    return courses.where((c) {
      final query = _searchController.text.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          c.title.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query) ||
          c.instructor.toLowerCase().contains(query);

      final matchesRating =
          _ratingRange == null ||
          (c.rating >= _ratingRange!.start && c.rating <= _ratingRange!.end);

      final matchesModules = _maxModules == null || c.modules <= _maxModules!;

      return matchesSearch && matchesRating && matchesModules;
    }).toList();
  }

  List<EnrolledLearningPath> _filterEnrolledCourses(List<EnrolledLearningPath> courses) {
    return courses.where((c) {
      final query = _searchController.text.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          c.title.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query) ||
          c.instructor.toLowerCase().contains(query);

      final matchesRating =
          _ratingRange == null ||
          (c.rating >= _ratingRange!.start && c.rating <= _ratingRange!.end);

      final matchesModules = _maxModules == null || c.modules <= _maxModules!;

      return matchesSearch && matchesRating && matchesModules;
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

    return Scaffold(
      appBar: AppBarWidget(title: 'Learning Paths', showBackButton: false),
      body: SafeArea(
        child: BlocBuilder<LearningPathBloc, LearningPathState>(
          builder: (context, state) {
            debugPrint('[UI] LearningPathOverviewPage - BlocBuilder state: ${state.runtimeType}');
            
            // Cache overview data when loaded
            if (state is LearningPathOverviewLoaded) {
              _cachedOverview = state;
            }
            
            // Show loading only if no cached data
            if ((state is LearningPathLoading || state is LearningPathInitial) && 
                _cachedOverview == null) {
              debugPrint('Showing loading indicator...');
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LearningPathError && _cachedOverview == null) {
              debugPrint('Error state: ${state.message}');
              return Center(child: Text(state.message));
            }

            // Use cached overview data
            final overviewData = _cachedOverview;
            if (overviewData != null) {
              debugPrint('Overview data available - All paths: ${overviewData.allPaths.length}, Enrolled: ${overviewData.enrolledPaths.length}');
              final filteredAll = _filterCourses(overviewData.allPaths);
              
              // Filter and deduplicate enrolled paths
              final filteredEnrolledWithDuplicates = _filterEnrolledCourses(overviewData.enrolledPaths);
              final seenPathIds = <String>{};
              final filteredEnrolled = filteredEnrolledWithDuplicates.where((path) {
                if (seenPathIds.contains(path.pathId)) {
                  return false;
                }
                seenPathIds.add(path.pathId);
                return true;
              }).toList();
              
              // Filter out enrolled paths from recommended section and all paths
              final enrolledPathIds = filteredEnrolled.map((e) => e.pathId).toSet();
              final filteredRecommended = filteredAll
                  .where((path) => !enrolledPathIds.contains(path.id))
                  .toList();
              
              // Use filtered courses (without enrolled) for "All Learning Paths" section
              final shownAllCourses = filteredRecommended.take(_allListShownCount).toList();

              // Check if user has enrolled paths (logged in)
              final hasEnrolledPaths = overviewData.enrolledPaths.isNotEmpty;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xmargin,
                    right: AppSpacing.xmargin,
                    top: AppSpacing.ymargin,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      const SizedBox(height: 40),

                      // ===== CONDITIONAL SECTION: MY LEARNING PATHS OR POPULAR =====
                      if (hasEnrolledPaths) ...[
                        // Logged in user: Show My Learning Paths
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Learning Paths',
                              style: AppPixelTypography.title.copyWith(
                                color: colors.onPrimary,
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
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<LearningPathBloc>(),
                                        child: const LearningPathStatusPage(),
                                      ),
                                    ),
                                  );
                                }


                              ),
                            ),
                          ],
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
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220,
                              mainAxisSpacing: 35,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.692, // 180/260 สำหรับ progress card
                            ),
                            itemBuilder: (context, index) {
                              return CourseProgressCard(data: filteredEnrolled[index]);
                            },
                          ),
                        const SizedBox(height: 60),

                        // Recommended for you section
                        Text(
                          'Recommended for you',
                          style: AppPixelTypography.title.copyWith(
                            color: colors.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          height: BaseCourseCard.defaultHeight,
                          child: filteredRecommended.isEmpty
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
                                  itemCount: filteredRecommended.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    return PixelCourseCard(course: filteredRecommended[index]);
                                  },
                                ),
                        ),
                      ] else ...[
                        // Not logged in: Show Popular Learning Paths
                        Text(
                          'Popular\nLearning Paths',
                          style: AppPixelTypography.title.copyWith(
                            color: colors.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          height: BaseCourseCard.defaultHeight,
                          child: filteredRecommended.isEmpty
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
                                  itemCount: filteredRecommended.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    return PixelCourseCard(course: filteredRecommended[index]);
                                  },
                                ),
                        ),
                      ],

                      const SizedBox(height: 60),

                      // ===== ALL LEARNING PATHS (COMMON FOR BOTH) =====
                      Text(
                        'All Learning Paths',
                        style: AppPixelTypography.title.copyWith(
                          color: colors.onPrimary,
                        ),
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

                      // ===== MORE BUTTON =====
                      if (_allListShownCount < filteredRecommended.length) ...[
                        const SizedBox(height: 40),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'More',
                                style: AppPixelTypography.smallTitle.copyWith(
                                  color: colors.onPrimary,
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
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
