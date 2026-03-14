import 'package:flutter/material.dart';

import 'package:passion_tree_frontend/core/theme/typography.dart';

import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';

class PopularLearningPathsSection extends StatelessWidget {
  final List<LearningPath> paths;

  const PopularLearningPathsSection({super.key, required this.paths});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (paths.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Learning Paths',
          style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
        ),

        const SizedBox(height: 40),

        SizedBox(
          height: BaseCourseCard.defaultHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: paths.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return PixelCourseCard(course: paths[index]);
            },
          ),
        ),
      ],
    );
  }
}
