import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/more_icon.dart';

class CourseProgressCard extends StatelessWidget {
  final EnrolledLearningPath data;

  const CourseProgressCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    
    final progress = (data.progressPercent / 100).clamp(0.0, 1.0);
    final percent = data.progressPercent.round();

    return BaseCourseCard(
      child: Column(
        children: [
          // ================= IMAGE =================
          SizedBox(
            height: 90,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    data.coverImgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: colors.primary.withValues(alpha: 0.15),
                        alignment: Alignment.center,
                        child: Text(
                          'NO IMAGE',
                          style: AppPixelTypography.smallTitle,
                        ),
                      );
                    },
                  ),
                ),

                // ---------- STAR BADGE ----------
                Positioned(
                  top: 3,
                  right: 3,
                  child: SizedBox(
                    width: 67,
                    height: 23,
                    child: Container(
                      color: colors.primary,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/Pixel_star.png',
                            width: 20,
                            height: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data.rating.toStringAsFixed(1),
                            style: AppTypography.bodySemiBold.copyWith(
                              color: colors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= INFO =================
          Expanded(
            child: Container(
              width: double.infinity,
              color: colors.surface,
              padding: EdgeInsets.all(AppSpacing.elementgap / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          style: AppTypography.subtitleSemiBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      MoreIcon(color: colors.onSurface),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'สอนโดย ${data.instructor}',
                    style: AppTypography.smallBodyMedium,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    data.description,
                    style: AppTypography.smallBodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // ================= PROGRESS HEADER =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: AppTypography.smallBodyMedium.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: AppTypography.smallBodyMedium.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ================= PROGRESS BAR =================
                  Container(
                    height: 10,
                    width: double.infinity,
                    color: colors.secondary,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(color: colors.primary),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ================= MODULE INFO =================
                  Text(
                    '${data.completedNodes} / ${data.modules} modules',
                    style: AppTypography.smallBodyMedium.copyWith(
                      color: colors.onSurface,
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
