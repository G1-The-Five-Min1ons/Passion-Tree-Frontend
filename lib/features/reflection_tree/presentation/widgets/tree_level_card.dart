import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/radio.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class TreeLevelCard extends StatelessWidget{
  final String imagePath;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const TreeLevelCard ({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isSelected = false,
  });

  factory TreeLevelCard.easy({required bool isSelected, required VoidCallback onTap}) {
    return TreeLevelCard(
      title: 'Easy',
      subtitle: 'Update Reflection Tree Monthly',
      imagePath: 'assets/images/trees/tree-level-easy.png',
      isSelected: isSelected,
      onTap: onTap,
    );
  }

  factory TreeLevelCard.medium({required bool isSelected, required VoidCallback onTap}) {
    return TreeLevelCard(
      title: 'Medium',
      subtitle: 'Update Reflection Tree Weekly',
      imagePath: 'assets/images/trees/tree-level-normal.png',
      isSelected: isSelected,
      onTap: onTap,
    );
  }

  factory TreeLevelCard.hard({required bool isSelected, required VoidCallback onTap}) {
    return TreeLevelCard(
      title: 'Hard',
      subtitle: 'Update Reflection Tree Daily',
      imagePath: 'assets/images/trees/tree-level-hard.png',
      isSelected: isSelected,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PixelBorderContainer(
        pixelSize: 4,
        borderColor: Theme.of(context).colorScheme.primary,
        fillColor: Theme.of(context).colorScheme.surface,
        width: double.infinity,
        height: 250,
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),

                Container(
                  width: 230,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: AppPixelTypography.smallTitle.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.bodyRegular.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
            top: 5,
            left: 5,
            child: PixelRadioButton(
              isSelected: isSelected,
              index: 0,
            ),
          )
          ],
        ),
      ),
    ); 
  }
}