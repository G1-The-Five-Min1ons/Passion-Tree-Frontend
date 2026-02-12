import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/radio.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class RatingSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const RatingSection({required this.title, required this.subtitle});

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
          initialValue: 0,
          showIndex: true,
          onSelected: (value) {
            // Handle the selected value
            print('Selected value: $value');
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
