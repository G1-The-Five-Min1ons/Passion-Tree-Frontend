import 'package:flutter/material.dart';

import 'package:passion_tree_frontend/core/theme/typography.dart';

import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';


class PopularLearningPathsSection extends StatelessWidget {
  final List<LearningPath> paths;
  final bool hasEnrolledPaths;
  final bool isLoading;

  const PopularLearningPathsSection({
    super.key,
    required this.paths,
    required this.hasEnrolledPaths,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (paths.isEmpty && !isLoading) return const SizedBox();

    final title = hasEnrolledPaths ? 'Recommended' : 'Popular Learning Paths';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
        ),
        const SizedBox(height: 30),
        SizedBox(
          height: BaseCourseCard.defaultHeight,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: paths.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return PixelCourseCard(course: paths[index]);
                  },
                ),
        ),
      ],
    );
  }
}
