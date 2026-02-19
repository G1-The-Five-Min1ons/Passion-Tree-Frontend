import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/more_icon.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_course.dart';
import 'package:passion_tree_frontend/core/common_widgets/popups/action_popup.dart';

class PixelCourseCard extends StatelessWidget {
  final LearningPath course;

  const PixelCourseCard({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(8), // ให้ ripple สวยตามการ์ด
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LearningCoursePage(
              course: course,
            ),
          ),
        );
      },
      child: BaseCourseCard(
        child: Column(
          children: [
            // ================= IMAGE =================
            SizedBox(
              height: 80,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      course.coverImageUrl,
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

                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          splashRadius: 20,
                          icon: MoreIcon(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () {
                            ActionPopUp.show(
                              context,
                              onEdit: () {
                                debugPrint('Edit course: ${course.title}');
                                // TODO: Add edit logic
                              },
                              onDelete: () {
                                debugPrint('Delete course: ${course.title}');
                                // TODO: Add delete logic
                              },
                            );
                          },
                        ),
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

                    const SizedBox(height: 10),

                    Text(
                      '${course.students} learners',
                      style: AppTypography.smallBodyMedium,
                    ),

                    Text(
                      '${course.modules} modules',
                      style: AppTypography.smallBodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
