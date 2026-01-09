import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class TeacherTabBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const TeacherTabBar({
    super.key,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabButton(
          label: 'Learning',
          isActive: activeIndex == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 12),
        _TabButton(
          label: 'Create',
          isActive: activeIndex == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: isActive
            ? BoxDecoration(color: Theme.of(context).colorScheme.primary)
            : null,
        child: Text(
          label,
          style: AppPixelTypography.smallTitle.copyWith(
            color: isActive
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
