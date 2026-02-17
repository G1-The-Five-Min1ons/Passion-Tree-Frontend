import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/node_item.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_canvas.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_asset.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/learning_nodes_mock.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';

class NodesOverviewCore extends StatelessWidget {
  final bool isEditable;
  final Function(int index)? onNodeTap;
  final List<NodeDetail>? nodes;

  const NodesOverviewCore({
    super.key,
    required this.isEditable,
    this.onNodeTap,
    this.nodes,
  });

  @override
  Widget build(BuildContext context) {
    // Use provided nodes or fallback to mock data
    final displayNodes = nodes ?? mockLearningNodes.map((mockNode) => NodeDetail(
      nodeId: 'mock-${mockNode.title}',
      title: mockNode.title,
      description: '',
      sequence: mockLearningNodes.indexOf(mockNode),
      pathId: '',
      materials: const [],
    )).toList();
    
    final nodeCount = displayNodes.length;
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
                        final node = displayNodes[index];
                        final mockNode = index < mockLearningNodes.length 
                            ? mockLearningNodes[index] 
                            : mockLearningNodes.first;

                        return Positioned(
                          left: pos.dx - 40,
                          top: pos.dy - 40,
                          child: NodeItem(
                            imagePath: NodeAsset.image(mockNode.state),
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
