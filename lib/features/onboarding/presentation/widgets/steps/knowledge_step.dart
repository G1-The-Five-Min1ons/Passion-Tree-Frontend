import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/utils/onboarding_constants.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/widgets/onboarding_choice_item.dart';

class KnowledgeStep extends StatelessWidget {
  final List<String> selected;
  final Function(List<String>) onSelect;

  const KnowledgeStep({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = OnboardingConstants.knowledgeLevels;

    return Column(
      key: const ValueKey('knowledge'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          OnboardingConstants.knowledgeQuestion,
          style: AppPixelTypography.h2.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 24),
        ...items.map((e) => OnboardingChoiceItem(
              label: e,
              isSelected: selected.contains(e),
              onTap: () => onSelect(selected.contains(e) ? [] : [e]),
            )),
      ],
    );
  }
}
