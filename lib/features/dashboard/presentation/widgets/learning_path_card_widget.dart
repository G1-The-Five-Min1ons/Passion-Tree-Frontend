import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_course.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

class LearningPathCardWidget extends StatelessWidget {
  final List<CurrentPathItem> paths;

  const LearningPathCardWidget({super.key, required this.paths});

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) {
      return PixelBorderContainer(
        width: double.infinity,
        pixelSize: 3,
        padding: const EdgeInsets.all(12),
        child: Text(
          'No learning paths enrolled yet',
          style: AppTypography.bodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Show the first enrolled path as the "current" path
    final path = paths.first;
    final progress = (path.progressPercent / 100).clamp(0.0, 1.0);
    final progressLabel = '${path.progressPercent.round()}%';

    return GestureDetector(
      onTap: () => _navigateToPath(context, path),
      child: PixelBorderContainer(
        width: double.infinity,
        pixelSize: 3,
        padding: const EdgeInsets.all(0),
        clipContent: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            path.coverImgUrl.isNotEmpty
                ? Image.network(
                    path.coverImgUrl,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 100,
                      color: AppColors.primaryBrand,
                      child: const Icon(
                        Icons.school,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 100,
                    color: AppColors.primaryBrand,
                    child: const Icon(
                      Icons.school,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    path.title,
                    style: AppTypography.subtitleSemiBold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (path.instructor.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'สอนโดย ${path.instructor}',
                      style: AppTypography.smallBodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (path.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      path.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.smallBodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Progress header
                  Row(
                    children: [
                      Text(
                        'Progress',
                        style: AppTypography.smallBodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        progressLabel,
                        style: AppTypography.smallBodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Progress bar
                  Container(
                    height: 8,
                    width: double.infinity,
                    color: AppColors.cardBorder,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(color: AppColors.secondaryBrand),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Module count
                  Text(
                    '${path.completedModules}/${path.totalModules} modules',
                    style: AppTypography.smallBodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (paths.length > 1) ...[
                    const SizedBox(height: 6),
                    Text(
                      '+ ${paths.length - 1} more learning path${paths.length - 1 > 1 ? 's' : ''}',
                      style: AppTypography.smallBodyRegular.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPath(BuildContext context, CurrentPathItem path) {
    final course = LearningPath(
      id: path.pathId,
      title: path.title,
      description: path.description,
      objective: '',
      coverImageUrl: path.coverImgUrl,
      rating: 0,
      publishStatus: 'published',
      instructor: path.instructor,
      students: 0,
      modules: path.totalModules,
      creatorId: '',
    );

    final enrolledPath = EnrolledLearningPath(
      pathId: path.pathId,
      title: path.title,
      description: path.description,
      instructor: path.instructor,
      rating: 0,
      coverImgUrl: path.coverImgUrl,
      modules: path.totalModules,
      completedNodes: path.completedModules,
      progressPercent: path.progressPercent,
      progressStatus: path.progressPercent >= 100 ? 'Completed' : 'In Progress',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<LearningPathBloc>(),
          child: LearningCoursePage(
            course: course,
            enrolledPath: enrolledPath,
          ),
        ),
      ),
    );
  }
}
