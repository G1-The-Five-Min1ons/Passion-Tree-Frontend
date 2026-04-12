import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_course.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

class LearningPathCardWidget extends StatelessWidget {
  final List<EnrolledLearningPath> enrolledPaths;

  const LearningPathCardWidget({super.key, required this.enrolledPaths});

  @override
  Widget build(BuildContext context) {
    if (enrolledPaths.isEmpty) {
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

    final path = enrolledPaths.first;
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
            _buildCoverImage(path.coverImgUrl),
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
                    '${path.completedNodes}/${path.modules} modules',
                    style: AppTypography.smallBodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (enrolledPaths.length > 1) ...[
                    const SizedBox(height: 6),
                    Text(
                      '+ ${enrolledPaths.length - 1} more learning path${enrolledPaths.length - 1 > 1 ? 's' : ''}',
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

  Widget _buildCoverImage(String coverImgUrl) {
    if (coverImgUrl.isEmpty) {
      return _buildCoverPlaceholder();
    }

    return Image.network(
      coverImgUrl,
      width: double.infinity,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _buildCoverPlaceholder(),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      width: double.infinity,
      height: 100,
      color: AppColors.primaryBrand,
      child: const Icon(
        Icons.school,
        size: 48,
        color: AppColors.textSecondary,
      ),
    );
  }

  void _navigateToPath(BuildContext context, EnrolledLearningPath path) {
    final course = LearningPath(
      id: path.pathId,
      title: path.title,
      description: path.description,
      objective: '',
      coverImageUrl: path.coverImgUrl,
      rating: path.rating,
      publishStatus: 'published',
      instructor: path.instructor,
      students: 0,
      modules: path.modules,
      creatorId: '',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<LearningPathBloc>(),
          child: LearningCoursePage(
            course: course,
            enrolledPath: path,
          ),
        ),
      ),
    );
  }
}
