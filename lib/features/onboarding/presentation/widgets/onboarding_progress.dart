import 'package:flutter/material.dart';

class OnboardingProgress extends StatelessWidget {
  final int step;
  final int total;

  const OnboardingProgress({
    super.key,
    required this.step,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (step + 1) / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("${step + 1}/$total"),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: progress, minHeight: 6),
      ],
    );
  }
}
