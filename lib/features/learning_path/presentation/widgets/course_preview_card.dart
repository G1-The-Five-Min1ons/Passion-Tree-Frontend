import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
class CoursePreviewCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String objectives;
  final String? imageUrl;
  final int? learners;
  final int? modules;

  const CoursePreviewCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.objectives,
    this.imageUrl,
    this.learners,
    this.modules,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BaseCourseCard(
      child: Column(
        children: [
          SizedBox(
            height: 90,
            width: double.infinity,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/placeholders/course_preview.png',
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/placeholders/course_preview.png',
                    fit: BoxFit.cover,
                  ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              color: colors.surface,
              padding: EdgeInsets.all(AppSpacing.elementgap / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? 'Path Title' : title,
                    style: AppTypography.subtitleSemiBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'สอนโดย $instructor',
                    style: AppTypography.smallBodyMedium,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    objectives.isEmpty ? 'Path objectives' : objectives,
                    style: AppTypography.smallBodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    learners != null ? '$learners learners' : 'x learners',
                    style: AppTypography.smallBodyMedium.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    modules != null ? '$modules modules' : 'x modules',
                    style: AppTypography.smallBodyMedium.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
