import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_progress_card.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_status_page.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';

class ContinueLearningSection extends StatelessWidget {
  final List<EnrolledLearningPath> enrolledPaths;

  const ContinueLearningSection({super.key, required this.enrolledPaths});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Filter to show only in-progress courses (not completed)
    final inProgressPaths = enrolledPaths
        .where((path) => path.progressStatus.toLowerCase() != 'completed')
        .toList();

    if (inProgressPaths.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Learning Paths',
              style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
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
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: inProgressPaths.length < 2 ? inProgressPaths.length : 2,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 35,
            crossAxisSpacing: 12,
            childAspectRatio: 0.692,
          ),
          itemBuilder: (context, index) {
            return CourseProgressCard(data: inProgressPaths[index]);
          },
        ),
      ],
    );
  }
}
