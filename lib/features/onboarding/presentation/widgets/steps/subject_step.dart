import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/utils/onboarding_constants.dart';
class SubjectStep extends StatelessWidget {
  final List<String> selected;
  final Function(List<String>) onSelect;

  const SubjectStep({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = OnboardingConstants.subjects;

    return Column(
      key: const ValueKey('subject'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          OnboardingConstants.subjectQuestion,
          style: AppPixelTypography.h2.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 24),
        Column(
          children: items.map((e) {
            final isSelected = selected.contains(e);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: InkWell(
                borderRadius: BorderRadius.zero,
                onTap: () {
                  final newSelected = List<String>.from(selected);
                  if (isSelected) {
                    newSelected.remove(e);
                  } else {
                    newSelected.add(e);
                  }
                  onSelect(newSelected);
                },
                child: PixelBorderContainer(
                  width: double.infinity,
                  height: 72,
                  borderColor: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  child: Center(
                    child: Text(
                      e,
                      style: AppTypography.titleSemiBold.copyWith(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
