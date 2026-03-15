import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class PageOneView extends StatelessWidget {
  final Function(String) onLearnChanged;
  final String initialValue;

  const PageOneView({super.key, required this.onLearnChanged, required this.initialValue});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          "What have you learned",
          style: AppTypography.h3Regular,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 12),
        PixelTextField(
          pixelSize: 3,
          hintText: 'Type what you have learned',
          height: 320,
          value: initialValue,
          onChanged: onLearnChanged,
        )
      ],
    );
  }
}