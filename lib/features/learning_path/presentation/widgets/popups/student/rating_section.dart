import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/radio.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class RatingSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function(int) onRatingChanged;
  final int? initialValue;

  const RatingSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onRatingChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleSemiBold.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTypography.subtitleRegular),
        const SizedBox(height: 12),

        // Add PixelRadioGroup with numbers inside the circles
        PixelRadioGroup(
          count: 5,
          initialValue: initialValue ?? 0,
          showIndex: true,
          onSelected: (value) {
            onRatingChanged(value);
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
