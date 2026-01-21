
import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/node_item.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_canvas.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_state.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_bottom.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/ai_node_review_page.dart';  
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_asset.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/learning_nodes_mock.dart';

class NodesOverviewPage extends StatefulWidget {
  const NodesOverviewPage({super.key});

  @override
  State<NodesOverviewPage> createState() => _NodesOverviewPageState();
}

class _NodesOverviewPageState extends State<NodesOverviewPage> {
  void _saveDraft() {
    debugPrint('Save draft nodes');
  }

  void _publish() {
    debugPrint('Publish learning path');
  }

  @override
  Widget build(BuildContext context) {
    final int nodeCount = mockLearningNodes.length;
    final double canvasHeight = (nodeCount * 200.0) + 200.0;

    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Nodes Overview',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER (FIXED) =====
            const HeaderBar(),

            // ===== SCROLLABLE CANVAS =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xmargin,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double canvasWidth = constraints.maxWidth;

                    return SizedBox(
                      height: canvasHeight,
                      child: TreeCanvas(
                        itemCount: nodeCount,
                        canvasWidth: canvasWidth, // width จริง
                        nodeBuilder: (index, pos) {
                          final node = mockLearningNodes[index];

                          return Positioned(
                            left: pos.dx - 40,
                            top: pos.dy - 40,
                            child: NodeItem(
                              imagePath: NodeAsset.image(node.state),
                              size: 80,
                              onTap: () {
                                // logic ทีหลัง
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            // ===== FLOATING BOTTOM BUTTONS =====
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: IgnorePointer(
                ignoring: false, // ปุ่มยังกดได้
                child: BottomBar(
                  onSaveDraft: _saveDraft,
                  onPublish: _publish,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



