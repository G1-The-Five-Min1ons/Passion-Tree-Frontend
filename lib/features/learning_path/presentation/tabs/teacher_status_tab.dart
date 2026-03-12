
import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_progress_card.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';

class TeacherLearningPathStatus extends StatefulWidget {
  final List<EnrolledLearningPath> enrolledPaths;

  const TeacherLearningPathStatus({
    super.key,
    required this.enrolledPaths,
  });

  @override
  State<TeacherLearningPathStatus> createState() => _TeacherLearningPathStatusState();
}

class _TeacherLearningPathStatusState extends State<TeacherLearningPathStatus> {
  int inProgressShown = 2;
  int completedShown = 2;

  // Cached filtered lists to avoid re-filtering on every build
  List<EnrolledLearningPath> _inProgressPaths = [];
  List<EnrolledLearningPath> _completedPaths = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredPaths();
  }

  @override
  void didUpdateWidget(TeacherLearningPathStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-filter only when data actually changes
    if (oldWidget.enrolledPaths != widget.enrolledPaths) {
      _updateFilteredPaths();
    }
  }

  /// Filter paths by progressStatus
  /// Called only when data changes, not on every build
  void _updateFilteredPaths() {
    _inProgressPaths = widget.enrolledPaths
        .where((c) => c.progressStatus != "Completed")
        .toList();
    
    _completedPaths = widget.enrolledPaths
        .where((c) => c.progressStatus == "Completed")
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    // Use cached filtered lists instead of filtering on every build
    final inProgressCourses = _inProgressPaths;
    final completedCourses = _completedPaths;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================================================
        // My Learning Paths - In progress
        // =====================================================
        Text(
          'My Learning Paths',
          style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 35,
              crossAxisSpacing: 12,
              childAspectRatio: 0.692, // 180/260 สำหรับ progress card
            ),
            itemBuilder: (context, index) {
              return CourseProgressCard(
                data: inProgressCourses[index],
              );
            },
          ),

        if (inProgressShown < inProgressCourses.length)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
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
                        inProgressShown += 2;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),


        const SizedBox(height: 60),

        // =====================================================
        // My Learning Paths - Completed
        // =====================================================
        Text(
          'My Learning Paths',
          style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 35,
              crossAxisSpacing: 12,
              childAspectRatio: 0.692, // 180/260 สำหรับ progress card
            ),
            itemBuilder: (context, index) {
              return CourseProgressCard(
                data: completedCourses[index],
              );
            },
          ),

        if (completedShown < completedCourses.length)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
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
                        completedShown += 2;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

      ],
    );
  }
}
