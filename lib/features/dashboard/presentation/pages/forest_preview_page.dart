// TEMPORARY DEV PREVIEW — delete when done
import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:passion_tree_frontend/features/dashboard/presentation/widgets/tree_card_widget.dart';

class ForestPreviewPage extends StatelessWidget {
  const ForestPreviewPage({super.key});

  static const _stages = [
    (trees: 0,   nodes: 0,   label: '0 Trees — Empty Garden'),
    (trees: 1,   nodes: 2,   label: '1 Tree — First Seedling'),
    (trees: 3,   nodes: 6,   label: '3 Trees — Sprouts'),
    (trees: 8,   nodes: 15,  label: '8 Trees — Small Forest'),
    (trees: 18,  nodes: 34,  label: '18 Trees — Medium Forest'),
    (trees: 30,  nodes: 58,  label: '30 Trees — Large Forest'),
    (trees: 50,  nodes: 95,  label: '50 Trees — Full Forest'),
    (trees: 80,  nodes: 150, label: '80 Trees — Dense Forest (max)'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.bar,
        title: Text(
          'Forest Preview (Dev)',
          style: AppTypography.bodySemiBold.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _stages.length,
        separatorBuilder: (_, _) => const SizedBox(height: 20),
        itemBuilder: (context, i) {
          final s = _stages[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.label,
                style: AppTypography.smallBodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TreeCardWidget(
                level: 1,
                treeStats: TreeCounterStats(
                  totalTreesPlanted: s.trees,
                  totalNodesUnlocked: s.nodes,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}