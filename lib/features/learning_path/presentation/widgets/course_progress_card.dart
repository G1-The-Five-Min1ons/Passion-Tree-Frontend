import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';

class CourseProgressCard extends StatelessWidget {
  final Course course;
  final int completedModules; 

  const CourseProgressCard({          
    super.key,
    required this.course,
    required this.completedModules,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final progress = (completedModules / course.modules).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

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
                  child: Image.asset(
                    course.imageAsset,
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
                            course.rating.toStringAsFixed(1),
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
                          course.title,
                          style: AppTypography.subtitleSemiBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.more_horiz, size: 16, color: colors.onSurface),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'สอนโดย ${course.instructor}',
                    style: AppTypography.smallBodyMedium,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    course.description,
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
                          color: colors.surface,
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: AppTypography.smallBodyMedium.copyWith(
                          color: colors.surface,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ================= PROGRESS BAR =================
                  Container(
                    height: 10,
                    width: double.infinity,
                    color: colors.secondary, // หลอดสีเหลือง
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        color: colors.primary, // สีน้ำเงิน progress
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ================= MODULE INFO =================
                  Text(
                    '$completedModules / ${course.modules} modules',
                    style: AppTypography.smallBodyMedium.copyWith(
                      color: colors.surface,
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
