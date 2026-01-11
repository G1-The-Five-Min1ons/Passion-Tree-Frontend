import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? initialCategory;
  final RangeValues? initialRatingRange;
  final int? initialModules;

  const FilterBottomSheet({
    super.key,
    this.initialCategory,
    this.initialRatingRange,
    this.initialModules,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _selectedCategory;
  late RangeValues _ratingRange;
  late int? _maxModules;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _ratingRange = widget.initialRatingRange ?? const RangeValues(0.0, 5.0);
    _maxModules = widget.initialModules;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasActiveFilters = _selectedCategory != null || 
                            (_ratingRange.start > 0.0 || _ratingRange.end < 5.0) ||
                            _maxModules != null;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: AppTypography.titleSemiBold.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                if (hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _ratingRange = const RangeValues(0.0, 5.0);
                        _maxModules = null;
                      });
                    },
                    child: Text(
                      'Reset',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filter Content (scrollable)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Section
                  Text(
                    'Category',
                    style: AppTypography.subtitleSemiBold.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildCategoryChip('All', null),
                      _buildCategoryChip('Science', 'Science'),
                      _buildCategoryChip('Technology', 'Technology'),
                      _buildCategoryChip('Law', 'Law'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Rating Section
                  Text(
                    'Rating Range',
                    style: AppTypography.subtitleSemiBold.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_ratingRange.start.toStringAsFixed(1)} ⭐',
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_ratingRange.end.toStringAsFixed(1)} ⭐',
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _ratingRange,
                    min: 0.0,
                    max: 5.0,
                    divisions: 10,
                    labels: RangeLabels(
                      _ratingRange.start.toStringAsFixed(1),
                      _ratingRange.end.toStringAsFixed(1),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _ratingRange = values;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Modules Section
                  Text(
                    'Maximum Modules',
                    style: AppTypography.subtitleSemiBold.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildModulesChip('≤10 modules', 10),
                      _buildModulesChip('≤15 modules', 15),
                      _buildModulesChip('≤20 modules', 20),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: colors.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Apply Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Return null for range if it's default (0.0 - 5.0)
                      final ratingToReturn = (_ratingRange.start == 0.0 && _ratingRange.end == 5.0) 
                          ? null 
                          : _ratingRange;
                      
                      Navigator.pop(context, {
                        'category': _selectedCategory,
                        'rating': ratingToReturn,
                        'modules': _maxModules,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = _selectedCategory == value;

    return FilterChip(
      key: ValueKey('category_${value ?? 'all'}'),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedCategory = value;
        });
      },
      backgroundColor: colors.surface,
      selectedColor: colors.primary.withValues(alpha: 0.2),
      checkmarkColor: colors.primary,
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: isSelected ? colors.primary : colors.onSurface,
      ),
      side: BorderSide(
        color: isSelected ? colors.primary : colors.outline,
        width: 1.5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildModulesChip(String label, int value) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = _maxModules == value;

    return FilterChip(
      key: ValueKey('modules_$value'),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _maxModules = isSelected ? null : value;
        });
      },
      backgroundColor: colors.surface,
      selectedColor: colors.primary.withValues(alpha: 0.2),
      checkmarkColor: colors.primary,
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: isSelected ? colors.primary : colors.onSurface,
      ),
      side: BorderSide(
        color: isSelected ? colors.primary : colors.outline,
        width: 1.5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
