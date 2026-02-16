import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/node_item.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_canvas.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_asset.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/learning_nodes_mock.dart';

class NodesOverviewCore extends StatelessWidget {
  final bool isEditable;
  final int nodeCount;
  final Function(int index)? onNodeTap;


  const NodesOverviewCore({
    super.key,
    required this.isEditable,
    this.nodeCount = 0,
    this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final canvasHeight = (nodeCount * 200.0) + 200.0;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xmargin),
          child: Column(
            children: [
              const SizedBox(height: 140),
              LayoutBuilder(
                builder: (context, constraints) {
                  final canvasWidth = constraints.maxWidth;

                  return SizedBox(
                    height: canvasHeight,
                    child: TreeCanvas(
                      itemCount: nodeCount,
                      canvasWidth: canvasWidth,
                      nodeBuilder: (index, pos) {


                        return Positioned(
                          left: pos.dx - 40,
                          top: pos.dy - 40,
                          child: NodeItem(
                            imagePath: NodeAsset.image(.locked),
                            size: 80,
                            onTap: () {
                              if (onNodeTap != null) {
                                onNodeTap!(index);
                              }
                            },

                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 320),
            ],
          ),
        ),
      ],
    );
  }
}
