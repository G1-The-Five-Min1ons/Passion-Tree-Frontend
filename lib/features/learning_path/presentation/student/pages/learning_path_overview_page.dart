import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_progress_card.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_status_page.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/all_learning_paths_page.dart';

class LearningPathOverviewPage extends StatefulWidget {
  const LearningPathOverviewPage({super.key});

  @override
  State<LearningPathOverviewPage> createState() =>
      _LearningPathOverviewPageState();
}

class _LearningPathOverviewPageState extends State<LearningPathOverviewPage> {
  String _searchQuery = '';
  LearningPathOverviewLoaded? _cachedOverview;

  String? userId;

  @override
  void initState() {
    super.initState();
    _loadOverviewData();
  }

  @override
  void dispose() {
    super.dispose();
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
    context.read<LearningPathBloc>().add(FetchLearningPathOverview());
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

  void _navigateToAllPaths(
    BuildContext context,
    List<LearningPath> paths,
  ) async {
    final bloc = context.read<LearningPathBloc>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: AllLearningPathsPage(paths: paths),
        ),
      ),
    );
    if (mounted && userId != null) {
      bloc.add(FetchLearningPathOverview());
    }
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
            if (state is NodeDetailLoaded || state is PathEnrolled) {
              if (userId != null && userId!.isNotEmpty) {
                context.read<LearningPathBloc>().add(
                  FetchLearningPathOverview(),
                );
              }
            }
          },
          child: BlocBuilder<LearningPathBloc, LearningPathState>(
            builder: (context, state) {
              if (state is LearningPathOverviewLoaded) {
                _cachedOverview = state;
              }

              if ((state is LearningPathLoading ||
                      state is LearningPathInitial) &&
                  _cachedOverview == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is LearningPathError && _cachedOverview == null) {
                return Center(child: Text(state.message));
              }

              final overviewData = _cachedOverview;
              if (overviewData == null) return const SizedBox();

              // Filter all published paths
              final filteredAll = _filterCourses(overviewData.allPaths).where((
                path,
              ) {
                final status = path.publishStatus.toLowerCase().trim();
                return status == 'published' &&
                    status.isNotEmpty &&
                    status != 'null';
              }).toList();

              // Deduplicate enrolled paths
              final filteredEnrolledWithDuplicates = _filterEnrolledCourses(
                overviewData.enrolledPaths,
              );
              final seenPathIds = <String>{};
              final filteredEnrolled = filteredEnrolledWithDuplicates.where((
                path,
              ) {
                if (seenPathIds.contains(path.pathId)) return false;
                seenPathIds.add(path.pathId);
                return true;
              }).toList();

              // Non-enrolled published paths (for recommendation + all section)
              final enrolledPathIds = overviewData.enrolledPaths
                  .map((e) => e.pathId.trim())
                  .toSet();
              final filteredRecommended = filteredAll
                  .where((path) => !enrolledPathIds.contains(path.id.trim()))
                  .toList();

              // First 4 for the overview "All Learning Paths" preview (excluding enrolled)
              final previewAllCourses = filteredRecommended.take(4).toList();
              final hasMorePaths =
                  filteredRecommended.length > previewAllCourses.length;

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
                      // ===== MY LEARNING PATHS (enrolled users) =====
                      if (hasEnrolledPaths) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Learning Paths',
                              style: AppPixelTypography.title.copyWith(
                                color: colors.onPrimary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
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
                                if (mounted && userId != null) {
                                  bloc.add(FetchLearningPathOverview());
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'See all',
                                    style: AppPixelTypography.smallTitle
                                        .copyWith(color: colors.onPrimary),
                                  ),
                                  const SizedBox(width: 6),
                                  Image.asset(
                                    'assets/buttons/navigation/pixel/right_small_light.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        if (filteredEnrolled.isEmpty)
                          SizedBox(
                            height: 260,
                            child: Center(
                              child: Text(
                                'No enrolled paths found',
                                style: AppTypography.subtitleSemiBold.copyWith(
                                  color: colors.onPrimary,
                                ),
                              ),
                            ),
                          )
                        else
                          Builder(
                              builder: (context) {
                                final count = filteredEnrolled.length.clamp(0, 4);
                                final gridHeight = count * BaseCourseCard.defaultHeight +
                                    (count > 1 ? (count - 1) * 35.0 : 0);
                                return SizedBox(
                                  height: gridHeight,
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: count,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 1,
                                          mainAxisSpacing: 35,
                                          mainAxisExtent: BaseCourseCard.defaultHeight,
                                        ),
                                    itemBuilder: (context, index) {
                                      return CourseProgressCard(
                                        data: filteredEnrolled[index],
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 40),
                        ],

                      // ===== ALL LEARNING PATHS =====
                      Text(
                        'All Learning Paths',
                        style: AppPixelTypography.title.copyWith(
                          color: colors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 40),

                      if (previewAllCourses.isEmpty)
                        SizedBox(
                          height: 260,
                          child: Center(
                            child: Text(
                              'No learning paths found',
                              style: AppTypography.subtitleSemiBold.copyWith(
                                color: colors.onPrimary,
                              ),
                            ),
                          ),
                        )
                      else
                        Builder(
                          builder: (context) {
                            final count = previewAllCourses.length;
                            final gridHeight = count * BaseCourseCard.defaultHeight +
                                (count > 1 ? (count - 1) * 35.0 : 0);
                            return SizedBox(
                              height: gridHeight,
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: count,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      mainAxisSpacing: 35,
                                      mainAxisExtent: BaseCourseCard.defaultHeight,
                                    ),
                                itemBuilder: (context, index) {
                                  return PixelCourseCard(
                                    course: previewAllCourses[index],
                                  );
                                },
                              ),
                            );
                          },
                        ),

                      if (hasMorePaths) ...[
                        const SizedBox(height: 32),
                        Center(
                          child: AppButton(
                            variant: AppButtonVariant.text,
                            text: 'View All',
                            icon: Icon(Icons.arrow_forward, size: 20, color: colors.onPrimary),
                            onPressed: () =>
                                _navigateToAllPaths(context, filteredRecommended),
                            textColor: colors.onPrimary,
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
