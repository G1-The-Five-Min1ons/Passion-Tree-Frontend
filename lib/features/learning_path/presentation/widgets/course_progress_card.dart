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
      height: 280, // เพิ่มความสูงสำหรับ progress card (จาก default 240)
      child: Column(
        children: [
          // ================= IMAGE =================
          SizedBox(
            height: 75, // ลดจาก 90 เพื่อให้มีพื้นที่สำหรับเนื้อหาข้างล่างมากขึ้น
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    data.coverImgUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colors.primary.withValues(alpha: 0.15),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: colors.onPrimary.withValues(alpha: 0.5),
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

                  const SizedBox(height: 3), // ลด spacing

                  Text(
                    'สอนโดย ${data.instructor}',
                    style: AppTypography.smallBodyMedium,
                  ),

                  const SizedBox(height: 6), // ลด spacing

                  Text(
                    data.description,
                    style: AppTypography.smallBodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8), // ลด spacing

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

                  const SizedBox(height: 4), // ลด spacing

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
