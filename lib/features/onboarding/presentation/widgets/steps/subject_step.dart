import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/utils/onboarding_constants.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/widgets/onboarding_choice_item.dart';

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
        ...items.map((e) {
          final isSelected = selected.contains(e);
          return OnboardingChoiceItem(
            label: e,
            isSelected: isSelected,
            onTap: () {
              final newSelected = List<String>.from(selected);
              if (isSelected) {
                newSelected.remove(e);
              } else {
                newSelected.add(e);
              }
              onSelect(newSelected);
            },
          );
        }),
      ],
    );
  }
}
