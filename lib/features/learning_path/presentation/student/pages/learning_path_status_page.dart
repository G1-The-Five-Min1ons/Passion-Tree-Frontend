import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_progress_card.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

class LearningPathStatusPage extends StatefulWidget {
  const LearningPathStatusPage({super.key});

  @override
  State<LearningPathStatusPage> createState() => _LearningPathStatusPageState();
}

class _LearningPathStatusPageState extends State<LearningPathStatusPage> {
  String _searchQuery = '';

  int inProgressShown = 2;
  int completedShown = 2;

  // Cache enrolled paths data
  List<EnrolledLearningPath>? _cachedEnrolledPaths;

  String? userId;

  @override
  void initState() {
    super.initState();
    _loadStatusData();
  }

  Future<void> _loadStatusData() async {
    final storedUserId = await getIt<IAuthRepository>().getUserId();
    if (!mounted) return;

    if (storedUserId != null && storedUserId.isNotEmpty) {
      setState(() => userId = storedUserId);
      context.read<LearningPathBloc>().add(
        FetchLearningPathStatus(userId: storedUserId),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<EnrolledLearningPath> _filterPaths(List<EnrolledLearningPath> paths) {
    final query = _searchQuery.trim().toLowerCase();

    return paths.where((p) {
      return query.isEmpty ||
          p.title.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query) ||
          p.instructor.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Learning Paths',
        showBackButton: true,
        onSearch: (q) => setState(() => _searchQuery = q),
      ),
      body: SafeArea(
        child: BlocBuilder<LearningPathBloc, LearningPathState>(
          builder: (context, state) {
            // Cache data when loaded
            if (state is LearningPathOverviewLoaded) {
              _cachedEnrolledPaths = state.enrolledPaths;
            } else if (state is LearningPathStatusLoaded) {
              _cachedEnrolledPaths = state.paths;
            }

            // Show loading only if no cached data
            if ((state is LearningPathLoading ||
                    state is LearningPathInitial) &&
                _cachedEnrolledPaths == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Use cached data or data from state
            final enrolledPaths =
                _cachedEnrolledPaths ??
                (state is LearningPathOverviewLoaded
                    ? state.enrolledPaths
                    : (state is LearningPathStatusLoaded ? state.paths : null));

            if (enrolledPaths != null) {
              final filtered = _filterPaths(enrolledPaths);

              // คอร์สที่กำลังเรียนอยู่ (In Progress)
              final inProgress = filtered
                  .where((p) => p.progressStatus != "Completed")
                  .toList();

              // คอร์สที่เรียนจบแล้ว (Completed)
              final completed = filtered
                  .where((p) => p.progressStatus == "Completed")
                  .toList();

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
                      // ================= IN PROGRESS =================
                      Text(
                        'My Learning Paths',
                        style: AppPixelTypography.title.copyWith(
                          color: colors.onPrimary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      RichText(
                        text: TextSpan(
                          style: AppPixelTypography.smallTitle.copyWith(
                            color: colors.onPrimary,
                          ),
                          children: [
                            const TextSpan(text: 'Status : '),
                            TextSpan(
                              text: 'In progress',
                              style: AppPixelTypography.smallTitle.copyWith(
                                color: colors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      if (inProgress.isEmpty)
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
                          itemCount: inProgress.length < inProgressShown
                              ? inProgress.length
                              : inProgressShown,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 35,
                                crossAxisSpacing: 12,
                                childAspectRatio:
                                    0.692, // 180/260 สำหรับ progress card
                              ),
                          itemBuilder: (context, index) {
                            return CourseProgressCard(data: inProgress[index]);
                          },
                        ),

                      if (inProgressShown < inProgress.length)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
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
                                      inProgressShown += 2;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 60),

                      // ================= COMPLETED =================
                      Text(
                        'My Learning Paths',
                        style: AppPixelTypography.title.copyWith(
                          color: colors.onPrimary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      RichText(
                        text: TextSpan(
                          style: AppPixelTypography.smallTitle.copyWith(
                            color: colors.onPrimary,
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

                      if (completed.isEmpty)
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
                          itemCount: completed.length < completedShown
                              ? completed.length
                              : completedShown,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                mainAxisSpacing: 35,
                                crossAxisSpacing: 12,
                                childAspectRatio:
                                    0.692, // 180/260 สำหรับ progress card
                              ),
                          itemBuilder: (context, index) {
                            return CourseProgressCard(data: completed[index]);
                          },
                        ),

                      if (completedShown < completed.length)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
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
                                      completedShown += 2;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }

            if (state is LearningPathError && _cachedEnrolledPaths == null) {
              return Center(child: Text(state.message));
            }

            // Default: show loading if no cached data available
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
