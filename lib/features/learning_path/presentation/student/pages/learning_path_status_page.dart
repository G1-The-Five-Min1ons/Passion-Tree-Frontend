import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_progress_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/search_bar.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';

class LearningPathStatusPage extends StatefulWidget {
  const LearningPathStatusPage({super.key});

  @override
  State<LearningPathStatusPage> createState() => _LearningPathStatusPageState();
}

class _LearningPathStatusPageState extends State<LearningPathStatusPage> {
  final TextEditingController _searchController = TextEditingController();

  int inProgressShown = 2;
  int completedShown = 2;

  @override
  void initState() {
    super.initState();

    debugPrint('[UI] LearningPathStatusPage - initState');
    
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

   List<EnrolledLearningPath> _filterPaths(List<EnrolledLearningPath> paths) {
    final query = _searchController.text.trim().toLowerCase();

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
      appBar: AppBarWidget(title: 'Learning Paths', showBackButton: true),
      body: SafeArea(
        child: BlocBuilder<LearningPathBloc, LearningPathState>(
          builder: (context, state) {
            debugPrint('[UI] LearningPathStatusPage - BlocBuilder state: ${state.runtimeType}');
            
             if (state is LearningPathLoading || state is LearningPathInitial) {
              debugPrint('Showing loading indicator...');
              return const Center(child: CircularProgressIndicator());
            }

            // Accept both states: from overview page or direct fetch
            if (state is LearningPathOverviewLoaded || state is LearningPathStatusLoaded) {
              final enrolledPaths = state is LearningPathOverviewLoaded 
                  ? state.enrolledPaths 
                  : (state as LearningPathStatusLoaded).paths;
              debugPrint('Enrolled paths loaded: ${enrolledPaths.length}');
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
                      LearningPathSearchBar(controller: _searchController),

                      const SizedBox(height: 40),

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
                                childAspectRatio: 0.692, // 180/260 สำหรับ progress card
                              ),
                          itemBuilder: (context, index) {
                            return CourseProgressCard(
                              data: inProgress[index],
                            );
                          },
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
                                childAspectRatio: 0.692, // 180/260 สำหรับ progress card
                              ),
                          itemBuilder: (context, index) {
                            return CourseProgressCard(data: completed[index]);
                          },
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }

            if (state is LearningPathError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
