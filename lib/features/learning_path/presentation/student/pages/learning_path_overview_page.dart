import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_progress_card.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_status_page.dart';

class LearningPathOverviewPage extends StatefulWidget {
  const LearningPathOverviewPage({super.key});

  @override
  State<LearningPathOverviewPage> createState() =>
      _LearningPathOverviewPageState();
}

class _LearningPathOverviewPageState extends State<LearningPathOverviewPage> {
  String _searchQuery = '';
  int _allListShownCount = 4;
  LearningPathOverviewLoaded? _cachedOverview;

  String? userId;

  @override
  void initState() {
    super.initState();
    _loadOverviewData();
  }

  Future<void> _loadOverviewData() async {
    final storedUserId = await getIt<IAuthRepository>().getUserId();
    if (storedUserId == null || storedUserId.isEmpty) {
      if (mounted) {
        context.read<LearningPathBloc>().add(FetchLearningPathOverview());
      }
      return;
    }
    if (!mounted) return;
    setState(() => userId = storedUserId);
    context.read<LearningPathBloc>().add(
      FetchLearningPathOverview(userId: userId),
    );
  }

  List<LearningPath> _filterCourses(List<LearningPath> courses) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return courses;
    return courses
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.description.toLowerCase().contains(q) ||
              c.instructor.toLowerCase().contains(q),
        )
        .toList();
  }

  List<EnrolledLearningPath> _filterEnrolledCourses(
    List<EnrolledLearningPath> courses,
  ) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return courses;
    return courses
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.description.toLowerCase().contains(q) ||
              c.instructor.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Learning Paths',
        showBackButton: false,
        onSearch: (q) => setState(() => _searchQuery = q),
      ),
      body: SafeArea(
        child: BlocListener<LearningPathBloc, LearningPathState>(
          listener: (context, state) {
            // Refetch overview when node is completed, path is enrolled, or path is updated/published
            if (state is NodeDetailLoaded || 
                state is PathEnrolled || 
                state is LearningPathUpdated) {
              if (userId != null && userId!.isNotEmpty) {
                // Add a small delay to ensure backend is updated
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    context.read<LearningPathBloc>().add(
                      FetchLearningPathOverview(userId: userId),
                    );
                  }
                });
              }
            }
          },
          child: BlocBuilder<LearningPathBloc, LearningPathState>(
            builder: (context, state) {
            // Cache overview data when loaded
            if (state is LearningPathOverviewLoaded) {
              _cachedOverview = state;
            }

            // Show loading only if no cached data
            if ((state is LearningPathLoading ||
                    state is LearningPathInitial) &&
                _cachedOverview == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LearningPathError && _cachedOverview == null) {
              return Center(child: Text(state.message));
            }

            // Use cached overview data
            final overviewData = _cachedOverview;
            if (overviewData != null) {
              // Filter by search query and published status only
              final filteredAll = _filterCourses(overviewData.allPaths)
                  .where((path) => path.publishStatus.toLowerCase() == 'published')
                  .toList();

              // Filter and deduplicate enrolled paths
              final filteredEnrolledWithDuplicates = _filterEnrolledCourses(
                overviewData.enrolledPaths,
              );
              final seenPathIds = <String>{};
              final filteredEnrolled = filteredEnrolledWithDuplicates.where((
                path,
              ) {
                if (seenPathIds.contains(path.pathId)) {
                  return false;
                }
                seenPathIds.add(path.pathId);
                return true;
              }).toList();

              // Filter out ALL enrolled paths (use original data to ensure complete filtering)
              final enrolledPathIds = overviewData.enrolledPaths
                  .map((e) => e.pathId)
                  .toSet();
              final filteredRecommended = filteredAll
                  .where((path) => !enrolledPathIds.contains(path.id))
                  .toList();

              // Use filtered courses (without enrolled) for "All Learning Paths" section
              final shownAllCourses = filteredRecommended
                  .take(_allListShownCount)
                  .toList();

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
                                onPressed: () async {
                                  final bloc = context.read<LearningPathBloc>();
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: bloc,
                                        child: const LearningPathStatusPage(),
                                      ),
                                    ),
                                  );
                                  // Refetch overview data when returning
                                  if (mounted && userId != null) {
                                    bloc.add(FetchLearningPathOverview(userId: userId));
                                  }
                                },
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
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 220,
                                  mainAxisSpacing: 35,
                                  crossAxisSpacing: 12,
                                  childAspectRatio:
                                      0.692, // 180/260 สำหรับ progress card
                                ),
                            itemBuilder: (context, index) {
                              return CourseProgressCard(
                                data: filteredEnrolled[index],
                              );
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
                                    style: AppTypography.subtitleSemiBold
                                        .copyWith(color: colors.onPrimary),
                                  ),
                                )
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                  ),
                                  itemCount: filteredRecommended.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    return PixelCourseCard(
                                      course: filteredRecommended[index],
                                    );
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
                                    style: AppTypography.subtitleSemiBold
                                        .copyWith(color: colors.onPrimary),
                                  ),
                                )
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                  ),
                                  itemCount: filteredRecommended.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    return PixelCourseCard(
                                      course: filteredRecommended[index],
                                    );
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
                            return PixelCourseCard(
                              course: shownAllCourses[index],
                            );
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
      ),
    );
  }
}
