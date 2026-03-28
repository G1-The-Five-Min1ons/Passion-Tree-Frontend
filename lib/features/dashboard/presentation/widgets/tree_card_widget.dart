import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';

class TreeCardWidget extends StatelessWidget {
  final int level;
  final TreeCounterStats? treeStats;

  const TreeCardWidget({
    super.key,
    required this.level,
    this.treeStats,
  });

  static const _treeAssets = [
    'assets/images/trees/tree-level-easy.png',
    'assets/images/trees/tree-level-normal.png',
    'assets/images/trees/tree-level-hard.png',
    'assets/images/trees/growing-happy.png',
    'assets/images/trees/growing-neutral.png',
  ];

  @override
  Widget build(BuildContext context) {
    final treesPlanted = treeStats?.totalTreesPlanted ?? 0;
    final nodesUnlocked = treeStats?.totalNodesUnlocked ?? 0;

    return PixelBorderContainer(
      width: double.infinity,
      pixelSize: 3,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header: count + nodes ---
          Row(
            children: [
              const Icon(Icons.park, size: 18, color: AppColors.secondaryBrand),
              const SizedBox(width: 6),
              Text(
                '$treesPlanted Tree${treesPlanted != 1 ? 's' : ''} Planted',
                style: AppTypography.bodySemiBold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$nodesUnlocked Nodes',
                style: AppTypography.smallBodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- Forest grid or empty state ---
          treesPlanted > 0
              ? _buildForestGrid(treesPlanted)
              : _buildEmptyGarden(),
        ],
      ),
    );
  }

  Widget _buildForestGrid(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBrand,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: List.generate(count, (i) {
          final asset = _treeAssets[i % _treeAssets.length];
          return Image.asset(
            asset,
            width: 44,
            height: 44,
            fit: BoxFit.contain,
          );
        }),
      ),
    );
  }

  Widget _buildEmptyGarden() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryBrand,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/trees/growing-neutral.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
            opacity: const AlwaysStoppedAnimation(0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Start learning to grow your forest!',
            style: AppTypography.smallBodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
