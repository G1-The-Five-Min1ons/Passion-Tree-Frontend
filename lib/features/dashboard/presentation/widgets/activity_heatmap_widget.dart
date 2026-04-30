import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';

class ActivityHeatmapWidget extends StatefulWidget {
  final List<ActivityHeatmapItem> heatmapData;

  const ActivityHeatmapWidget({super.key, required this.heatmapData});

  @override
  State<ActivityHeatmapWidget> createState() => _ActivityHeatmapWidgetState();
}

class _ActivityHeatmapWidgetState extends State<ActivityHeatmapWidget> {
  static const _rows = 7;
  static const _cols = 12;
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String? _selectedInfo;

  late final DateTime _startDate;
  late final Map<String, int> _counts;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    // Start on the Monday of the week that is (_cols-1) weeks before today's week,
    // so today always lands in the last column at its correct weekday row.
    _startDate = today.subtract(
      Duration(days: (_cols - 1) * _rows + (today.weekday - 1)),
    );

    _counts = {};
    for (final item in widget.heatmapData) {
      _counts[item.date] = item.count;
    }
  }

  DateTime _dateAt(int col, int row) {
    return _startDate.add(Duration(days: col * _rows + row));
  }

  String _dateStr(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int _levelAt(int col, int row) {
    final date = _dateAt(col, row);
    final count = _counts[_dateStr(date)] ?? 0;
    if (count == 0) return 0;
    if (count <= 1) return 1;
    if (count <= 3) return 2;
    return 3;
  }

  void _onCellTap(int col, int row) {
    final date = _dateAt(col, row);
    final count = _counts[_dateStr(date)] ?? 0;
    setState(() {
      _selectedInfo =
          '${date.day} ${_months[date.month - 1]} ${date.year} — $count activit${count == 1 ? 'y' : 'ies'}';
    });
  }

  List<String> _getMonthLabels() {
    final labels = <_MonthLabel>[];
    int? lastMonth;

    for (int col = 0; col < _cols; col++) {
      final date = _dateAt(col, 0);
      if (date.month != lastMonth) {
        labels.add(_MonthLabel(_months[date.month - 1], col));
        lastMonth = date.month;
      }
    }
    return List.generate(_cols, (col) {
      final match = labels.where((l) => l.col == col);
      return match.isNotEmpty ? match.first.label : '';
    });
  }

  Color _getColor(int level) {
    if (level == 0) return AppColors.activityfour;
    if (level == 1) return AppColors.activitythree;
    if (level == 2) return AppColors.activitytwo;
    return AppColors.activityone;
  }

  @override
  Widget build(BuildContext context) {
    final monthLabels = _getMonthLabels();

    return PixelBorderContainer(
      width: double.infinity,
      pixelSize: 3,
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellGap = 3.0;
            final totalGap = cellGap * (_cols - 1);
            final cellSize = (constraints.maxWidth - totalGap) / _cols;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Month labels ---
                Row(
                  children: List.generate(_cols, (col) {
                    final label = monthLabels[col];
                    return SizedBox(
                      width: col < _cols - 1 ? cellSize + cellGap : cellSize,
                      child: label.isNotEmpty
                          ? Text(
                              label.toUpperCase(),
                              style: AppTypography.smallBodyRegular.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  }),
                ),
              const SizedBox(height: 6),

              // --- Heatmap grid ---
              ...List.generate(_rows, (row) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: row < _rows - 1 ? cellGap : 0,
                  ),
                  child: Row(
                    children: List.generate(_cols, (col) {
                      final level = _levelAt(col, row);
                      return GestureDetector(
                        onTap: () => _onCellTap(col, row),
                        child: Container(
                          width: cellSize,
                          height: cellSize,
                          margin: EdgeInsets.only(
                            right: col < _cols - 1 ? cellGap : 0,
                          ),
                          color: _getColor(level),
                        ),
                      );
                    }),
                  ),
                );
              }),
              const SizedBox(height: 8),

              // --- Selected date info + legend ---
              Row(
                children: [
                  Expanded(
                    child: _selectedInfo != null
                        ? Text(
                            _selectedInfo!,
                            style: AppTypography.smallBodyRegular.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          )
                        : Text(
                            'Tap a cell to see date',
                            style: AppTypography.smallBodyRegular.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                  ),
                  Text(
                    'LESS',
                    style: AppTypography.smallBodyRegular.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ...[0, 1, 2, 3].map(
                    (level) => Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 2),
                      color: _getColor(level),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'MORE',
                    style: AppTypography.smallBodyRegular.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MonthLabel {
  final String label;
  final int col;
  _MonthLabel(this.label, this.col);
}
