import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_course.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';

class RecommendationCard extends StatelessWidget {
  final LearningPath course;

  const RecommendationCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width - 48;
        final cardHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 300.0;
        final imageHeight = (cardHeight * 0.5).clamp(120.0, 180.0).toDouble();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<LearningPathBloc>(),
                  child: LearningCoursePage(course: course),
                ),
              ),
            );
          },
          child: BaseCourseCard(
            width: cardWidth,
            height: cardHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== COVER IMAGE =====
                SizedBox(
                  width: double.infinity,
                  height: imageHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          course.coverImageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: colors.primary.withValues(alpha: 0.1),
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colors.primary.withValues(alpha: 0.15),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.broken_image,
                                size: 64,
                                color: colors.onPrimary.withValues(alpha: 0.4),
                              ),
                            );
                          },
                        ),
                      ),

                      /// Gradient overlay at bottom of image
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 76,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                colors.surface.withValues(alpha: 0.85),
                              ],
                            ),
                          ),
                        ),
                      ),

                      

                      /// Rating badge
                      Positioned(
                        top: 3,
                        right: 3,
                        child: Container(
                          color: AppColors.cardBorder,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
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
                    ],
                  ),
                ),

                /// ===== INFO SECTION =====
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: colors.surface,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title
                        Text(
                          course.title,
                          style: AppTypography.subtitleSemiBold.copyWith(
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 3),

                        /// Instructor
                        Text(
                          'สอนโดย ${course.instructor}',
                          style: AppTypography.smallBodyMedium.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.75),
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// Description
                        Expanded(
                          child: Text(
                            course.description,
                            style: AppTypography.smallBodyMedium.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        /// Stats row
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 13,
                              color: colors.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${course.students}',
                              style: AppTypography.smallBodyMedium.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.grid_view_rounded,
                              size: 13,
                              color: colors.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${course.modules} modules',
                              style: AppTypography.smallBodyMedium.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
