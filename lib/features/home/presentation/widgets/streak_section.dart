import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class StreakSection extends StatelessWidget {
  final int streakCount;

  const StreakSection({super.key, required this.streakCount});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Build a 5-day window centered on the current streak day
    final int centerDay = streakCount > 0 ? streakCount : 1;
    final int startDay = (centerDay - 2).clamp(1, double.maxFinite.toInt());

    return PixelBorderContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              streakCount > 0
                  ? "$streakCount day${streakCount == 1 ? '' : 's'} on streak!"
                  : "Start your streak today!",
              style: AppPixelTypography.smallTitle.copyWith(
                color: colors.onPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final day = startDay + i;
                return _DayBox(
                  label: '${day}D',
                  state: day < centerDay
                      ? _DayState.completed
                      : day == centerDay && streakCount > 0
                      ? _DayState.current
                      : _DayState.locked,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

enum _DayState { completed, current, locked }

class _DayBox extends StatelessWidget {
  final String label;
  final _DayState state;

  const _DayBox({required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color iconColor;

    switch (state) {
      case _DayState.completed:
        icon = Icons.check_circle;
        iconColor = AppColors.submit;
        break;
      case _DayState.current:
        icon = Icons.local_fire_department;
        iconColor = AppColors.secondaryBrand;
        break;
      case _DayState.locked:
        icon = Icons.local_fire_department;
        iconColor = AppColors.scale;
        break;
    }

    return Column(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: state == _DayState.locked
                ? AppColors.textSecondary
                : AppColors.textPrimary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
