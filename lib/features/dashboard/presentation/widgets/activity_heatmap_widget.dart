import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';

class ActivityHeatmapWidget extends StatelessWidget {
  final List<ActivityHeatmapItem> heatmapData;

  const ActivityHeatmapWidget({super.key, required this.heatmapData});

  @override
  Widget build(BuildContext context) {
    // Build a 7-row x 14-column grid from real data (last ~98 days)
    final grid = _buildGrid();
    final monthLabels = _getMonthLabels();

    return PixelBorderContainer(
      pixelSize: 3,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: monthLabels
                .map(
                  (label) => Text(
                    label,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          ...grid.map(
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

  /// Convert raw heatmap data into a 7x14 grid.
  /// Each cell is an activity level (0-3).
  List<List<int>> _buildGrid() {
    // Build a date->count map from API data
    final counts = <String, int>{};
    for (final item in heatmapData) {
      counts[item.date] = item.count;
    }

    const rows = 7;
    const cols = 14;
    const totalDays = rows * cols; // 98 days

    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: totalDays - 1));

    // Fill grid column by column (each column = 1 week of 7 days)
    final grid = List.generate(rows, (_) => List.filled(cols, 0));

    for (int col = 0; col < cols; col++) {
      for (int row = 0; row < rows; row++) {
        final dayIndex = col * rows + row;
        final date = startDate.add(Duration(days: dayIndex));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final count = counts[dateStr] ?? 0;
        // Map count to activity level 0-3
        grid[row][col] = _countToLevel(count);
      }
    }

    return grid;
  }

  int _countToLevel(int count) {
    if (count == 0) return 0;
    if (count <= 1) return 1;
    if (count <= 3) return 2;
    return 3;
  }

  List<String> _getMonthLabels() {
    const totalDays = 98;
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: totalDays - 1));
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];

    final labels = <String>{};
    for (int i = 0; i < totalDays; i += 14) {
      final date = startDate.add(Duration(days: i));
      labels.add(months[date.month - 1]);
    }
    return labels.toList();
  }

  Color _getColor(int level) {
    if (level == 0) return AppColors.activityfour;
    if (level == 1) return AppColors.activitythree;
    if (level == 2) return AppColors.activitytwo;
    return AppColors.activityone;
  }
}
