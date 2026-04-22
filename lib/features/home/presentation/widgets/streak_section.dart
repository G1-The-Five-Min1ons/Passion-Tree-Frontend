import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class StreakSection extends StatelessWidget {
  const StreakSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PixelBorderContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "14 days on streak!",
              style: AppPixelTypography.smallTitle.copyWith(color: colors.onPrimary),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _DayBox("11D"),
                _DayBox("12D"),
                _DayBox("13D"),
                _DayBox("14D"),
                _DayBox("15D"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayBox extends StatelessWidget {
  final String label;

  const _DayBox(this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            Icons.local_fire_department,
            color: AppColors.secondaryBrand,
            size: 28,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
