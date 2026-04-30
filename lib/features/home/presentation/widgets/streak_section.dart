import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

const _kDayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

enum _DayState { completed, current, inactive }

class StreakSection extends StatelessWidget {
  final int streakCount;

  const StreakSection({super.key, required this.streakCount});

  String get _motivationalText {
    if (streakCount == 0) return 'Start your streak today!';
    if (streakCount < 3) return 'Good start! Keep it up!';
    if (streakCount < 7) return 'Keep the fire alive!';
    if (streakCount < 14) return 'This is your longest streak!';
    if (streakCount < 30) return "You're on fire! Amazing!";
    return "Legendary! You're unstoppable!";
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun

    final width = MediaQuery.of(context).size.width;
    final scale = (width / 360).clamp(0.85, 1.4);

    return PixelBorderContainer(
      padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 20 * scale, 24 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streakCount',
                    style: AppPixelTypography.h1.copyWith(
                      color: streakCount > 0
                          ? AppColors.secondaryBrand
                          : AppColors.textSecondary,
                      fontSize: 52 * scale,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    'Streak Days !',
                    style: AppTypography.titleSemiBold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.local_fire_department_rounded,
                color: streakCount > 0
                    ? AppColors.secondaryBrand
                    : AppColors.textDisabled,
                size: 72 * scale,
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          Text(
            _motivationalText,
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 20 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final dayIndex = i + 1;
              final daysAgo = today - dayIndex;

              final _DayState state;
              if (daysAgo == 0 && streakCount > 0) {
                state = _DayState.current;
              } else if (daysAgo > 0 && daysAgo < streakCount) {
                state = _DayState.completed;
              } else {
                state = _DayState.inactive;
              }

              return _DayDot(label: _kDayLabels[i], state: state, scale: scale as double);
            }),
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String label;
  final _DayState state;
  final double scale;

  const _DayDot({required this.label, required this.state, required this.scale});

  @override
  Widget build(BuildContext context) {
    final Color fireColor = state == _DayState.inactive
        ? AppColors.textDisabled
        : AppColors.secondaryBrand;
    final Color labelColor = state == _DayState.inactive
        ? AppColors.textDisabled
        : AppColors.textPrimary;
    final Color dotBg = switch (state) {
      _DayState.current => const Color(0xFF2E1F00),
      _DayState.completed => const Color(0xFF243060),
      _DayState.inactive => AppColors.cardBorder,
    };
    return Column(
      children: [
        Container(
          width: 36 * scale,
          height: 36 * scale,
          decoration: BoxDecoration(
            color: dotBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_fire_department_rounded,
            color: fireColor,
            size: 28 * scale,
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          label,
          style: AppTypography.smallBodyRegular.copyWith(
            color: labelColor,
            fontSize: 9 * scale,
          ),
        ),
      ],
    );
  }
}
