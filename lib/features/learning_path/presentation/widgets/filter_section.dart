import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/filter_bottom_sheet.dart';

class FilterSection extends StatelessWidget {
  final String? selectedCategory;
  final RangeValues? ratingRange;
  final int? maxModules;
  final Function(String?, RangeValues?, int?) onFiltersChanged;

  const FilterSection({
    super.key,
    required this.selectedCategory,
    required this.ratingRange,
    required this.maxModules,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasActiveFilters = selectedCategory != null || 
                            ratingRange != null || 
                            maxModules != null;

    return InkWell(
      onTap: () async {
        final result = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FilterBottomSheet(
            initialCategory: selectedCategory,
            initialRatingRange: ratingRange,
            initialModules: maxModules,
          ),
        );

        if (result != null) {
          onFiltersChanged(
            result['category'] as String?,
            result['rating'] as RangeValues?,
            result['modules'] as int?,
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasActiveFilters ? colors.primary : colors.outline,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: hasActiveFilters 
              ? colors.primary.withValues(alpha: 0.05)
              : colors.surface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/filter_search.png',
              width: 20,
              height: 20,
              color: hasActiveFilters ? colors.primary : colors.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              '',
              style: AppTypography.bodyMedium.copyWith(
                color: hasActiveFilters ? colors.primary : colors.onSurface,
              ),
            ),
            if (hasActiveFilters) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getActiveFilterCount().toString(),
                  style: AppTypography.smallBodyMedium.copyWith(
                    color: colors.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (selectedCategory != null) count++;
    if (ratingRange != null) count++;
    if (maxModules != null) count++;
    return count;
  }
}