import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';

class ActivityHeatmapWidget extends StatelessWidget {
  const ActivityHeatmapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const levels = [
      [0, 1, 1, 2, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3],
      [1, 1, 2, 3, 1, 1, 2, 3, 3, 2, 1, 2, 3, 1],
      [0, 1, 1, 2, 2, 1, 0, 1, 2, 3, 2, 1, 1, 0],
      [0, 0, 1, 2, 3, 2, 1, 1, 2, 3, 3, 2, 1, 1],
      [1, 2, 3, 3, 2, 1, 1, 0, 1, 2, 3, 2, 1, 0],
      [1, 2, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3],
      [0, 1, 1, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2],
    ];

    return PixelBorderContainer(
      pixelSize: 3,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('MAR', style: TextStyle(color: AppColors.textSecondary)),
              Text('APR', style: TextStyle(color: AppColors.textSecondary)),
              Text('MAY', style: TextStyle(color: AppColors.textSecondary)),
              Text('JUN', style: TextStyle(color: AppColors.textSecondary)),
              Text('JUL', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          ...levels.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: row
                    .map(
                      (cell) => Container(
                        width: 11,
                        height: 11,
                        margin: const EdgeInsets.only(right: 3),
                        color: _getColor(cell),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'LESS',
                style: AppTypography.smallBodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              ...[0, 1, 2, 3].map(
                (level) => Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 3),
                  color: _getColor(level),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'MORE',
                style: AppTypography.smallBodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColor(int level) {
    if (level == 0) return AppColors.background;
    if (level == 1) return AppColors.surface;
    if (level == 2) return AppColors.primaryBrand;
    return AppColors.status;
  }
}
