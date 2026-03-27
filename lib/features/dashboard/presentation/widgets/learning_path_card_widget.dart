import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';

class LearningPathCardWidget extends StatelessWidget {
  final List<CurrentPathItem> paths;

  const LearningPathCardWidget({super.key, required this.paths});

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) {
      return PixelBorderContainer(
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

    return PixelBorderContainer(
      pixelSize: 3,
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            child: Stack(
              children: [
                // Use network image if available, otherwise fallback
                path.coverImgUrl.isNotEmpty
                    ? Image.network(
                        path.coverImgUrl,
                        width: double.infinity,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: double.infinity,
                          height: 130,
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
                        height: 130,
                        color: AppColors.primaryBrand,
                        child: const Icon(
                          Icons.school,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                      ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  path.title,
                  style: AppTypography.subtitleSemiBold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Progress',
                  style: AppTypography.smallBodyRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.cardBorder,
                  color: AppColors.secondaryBrand,
                  minHeight: 7,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    progressLabel,
                    style: AppTypography.smallBodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                // Show remaining paths count
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
    );
  }
}
