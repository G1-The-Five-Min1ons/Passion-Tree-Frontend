import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_course.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/layout/fullscreen_image_viewer.dart';

class CourseProgressCard extends StatelessWidget {
  final EnrolledLearningPath data;

  const CourseProgressCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final descriptionStyle = AppTypography.smallBodyMedium;
    final textScaler = MediaQuery.textScalerOf(context);
    final descriptionHeightPainter = TextPainter(
      text: TextSpan(text: 'A\nA', style: descriptionStyle),
      maxLines: 2,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();
    final descriptionBlockHeight = descriptionHeightPainter.height + 2;

    final progress = (data.progressPercent / 100).clamp(0.0, 1.0);
    final percent = data.progressPercent.round();

    // Convert EnrolledLearningPath to LearningPath for navigation
    final course = LearningPath(
      id: data.pathId,
      title: data.title,
      description: data.description,
      objective: '',
      coverImageUrl: data.coverImgUrl,
      rating: data.rating,
      publishStatus: 'Published',
      instructor: data.instructor,
      students: 0,
      modules: data.modules,
      creatorId: '', // Not available from EnrolledLearningPath
    );

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<LearningPathBloc>(),
              child: LearningCoursePage(course: course, enrolledPath: data),
            ),
          ),
        );
      },
      child: BaseCourseCard(
        child: Column(
          children: [
            SizedBox(
              height: 90,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: data.coverImgUrl.isEmpty
                          ? null
                          : () => FullscreenImageViewer.show(
                                context,
                                imageUrl: data.coverImgUrl,
                              ),
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
                  ),
                  Positioned(
                    top: 3,
                    right: 3,
                    child: SizedBox(
                      width: 67,
                      height: 23,
                      child: Container(
                        color: AppColors.cardBorder,
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
            Expanded(
              child: Container(
                width: double.infinity,
                color: colors.surface,
                padding: EdgeInsets.all(AppSpacing.elementgap / 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: AppTypography.subtitleSemiBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'สอนโดย ${data.instructor}',
                      style: AppTypography.smallBodyMedium,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: descriptionBlockHeight,
                      child: Text(
                        data.description,
                        style: descriptionStyle,
                        strutStyle: StrutStyle.fromTextStyle(
                          descriptionStyle,
                          forceStrutHeight: true,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.cardBorder,
                        color: AppColors.secondaryBrand,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
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
      ),
    );
  }
}
