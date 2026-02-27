import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/node_item.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_canvas.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_asset.dart';
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
    // Use provided nodes from backend
    final displayNodes = nodes ?? [];
    
    final nodeCount = displayNodes.length;
    final canvasHeight = (nodeCount * 200.0) + 200.0;
    
    // Find the latest active node (highest sequence number with active status and not completed)
    NodeDetail? latestActiveNode;
    for (final node in displayNodes) {
      if (node.status.toLowerCase() == 'active' && node.complete.toLowerCase() != 'true') {
        if (latestActiveNode == null || node.sequence > latestActiveNode.sequence) {
          latestActiveNode = node;
        }
      }
    }

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
                        // Convert API status to LearningNodeState
                        final nodeState = NodeAsset.statusToState(node.status);
                        
                        // Check if this is the latest active node
                        final isLatestActiveNode = latestActiveNode != null && 
                                                   node.nodeId == latestActiveNode.nodeId;
                      
                        return Positioned(
                          left: pos.dx - 40,
                          top: pos.dy - 40,
                          child: NodeItem(
                            imagePath: NodeAsset.image(nodeState),
                            size: 80,
                            showCurrentIndicator: isLatestActiveNode,
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
