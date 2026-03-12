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

    // เรียงลำดับตามจำนวน learners (students) และ rating
    final sortedPaths = List<LearningPath>.from(paths)
      ..sort((a, b) {
        // เรียงตาม students ก่อน (มากไปน้อย)
        final studentCompare = b.students.compareTo(a.students);
        if (studentCompare != 0) return studentCompare;

        // ถ้า students เท่ากัน ให้เรียงตาม rating (มากไปน้อย)
        return b.rating.compareTo(a.rating);
      });

    // จำกัดจำนวนที่แสดง (แสดงแค่ 10 อันดับแรก)
    final popularPaths = sortedPaths.take(10).toList();

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
            itemCount: popularPaths.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return PixelCourseCard(course: popularPaths[index]);
            },
          ),
        ),
      ],
    );
  }
}
