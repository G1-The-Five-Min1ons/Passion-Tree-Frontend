import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/arrow_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class SearchDropdown extends StatefulWidget {
  final List<String> options;
  final String label;
  final Function(String) onSelected;
  final SearchController controller;

  const SearchDropdown ({
    super.key,
    required this.options,
    required this.label,
    required this.onSelected,
    required this.controller,
  });

  @override
  State<SearchDropdown> createState() => _SearchDropdownState();
}

class _SearchDropdownState extends State<SearchDropdown> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final allOptions = widget.options;

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isOpen = !_isOpen),
          child: PixelBorderContainer(
            pixelSize: 4,
            borderColor: Theme.of(context).colorScheme.primary,
            fillColor: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.controller.text.isEmpty ? widget.label : widget.controller.text,
                    style: AppTypography.subtitleSemiBold.copyWith(
                      color: widget.controller.text.isEmpty 
                          ? AppColors.textSecondary 
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                ArrowButton(
                  direction: _isOpen ? ArrowDirection.up : ArrowDirection.down,
                  onPressed: () {
                      setState(() => _isOpen = !_isOpen);
                    },
                  color: AppColors.textSecondary,
                  size: 30,
                ),
              ],
            ),
          ),
        ),

        if (_isOpen && allOptions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: allOptions.length,
              itemBuilder: (context, index) {
                final option = allOptions[index];
                return ListTile(
                  title: Text(
                    option,
                    style: AppTypography.subtitleSemiBold.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    widget.onSelected(option);
                    widget.controller.text = option;
                    setState(() => _isOpen = false);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}