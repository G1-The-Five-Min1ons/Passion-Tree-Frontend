import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/node_item.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_canvas.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_asset.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/learning_nodes_mock.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/teacher_nodes_overview.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_state.dart';

class NodesOverviewCore extends StatelessWidget {
  final bool isEditable;
  final List<NodeUiState> nodeUiList;
  final Function(int index)? onNodeTap;


  const NodesOverviewCore({
    super.key,
    required this.isEditable,
    required this.nodeUiList,
    this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final nodeCount = nodeUiList.length;
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
                        final node = nodeUiList[index];
                        final imageAsset = node.isCreated
                            ? NodeAsset.image(LearningNodeState.active) 
                            : NodeAsset.image(LearningNodeState.locked);

                        return Positioned(
                          left: pos.dx - 40,
                          top: pos.dy - 40,
                          child: NodeItem(
                            imagePath: imageAsset,
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
