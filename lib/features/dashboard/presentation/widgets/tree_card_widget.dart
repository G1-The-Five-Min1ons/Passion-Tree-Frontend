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

  @override
  Widget build(BuildContext context) {
    final treesPlanted = treeStats?.totalTreesPlanted ?? 0;
    final nodesUnlocked = treeStats?.totalNodesUnlocked ?? 0;

    return PixelBorderContainer(
      pixelSize: 3,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/trees/tree-level-normal.png',
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              const Icon(Icons.park, color: AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                '$treesPlanted Tree${treesPlanted != 1 ? 's' : ''}',
                style: AppTypography.subtitleSemiBold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$nodesUnlocked Nodes',
                style: AppTypography.smallBodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
