
import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/node_item.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_canvas.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_bottom.dart';

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
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const AppBarWidget(title: 'Nodes Overview', showBackButton: true),
      body: SafeArea(
        child: Stack(
          children: [
            // ===== SCROLLABLE CONTENT (ทั้งหน้า) =====
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xmargin,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 120), // เว้นที่ให้ header ลอย

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double canvasWidth = constraints.maxWidth;

                      return SizedBox(
                        height: canvasHeight,
                        child: TreeCanvas(
                          itemCount: nodeCount,
                          canvasWidth: canvasWidth,
                          nodeBuilder: (index, pos) {
                            final node = mockLearningNodes[index];

                            return Positioned(
                              left: pos.dx - 40,
                              top: pos.dy - 40,
                              child: NodeItem(
                                imagePath: NodeAsset.image(node.state),
                                size: 80,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 300), // เว้นที่ให้ปุ่มลอย
                ],
              ),
            ),

            // ===== HEADER (FLOATING) =====
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: HeaderBar(),
              ),
            ),


            // ===== FLOATING BUTTONS =====
            Positioned(
              left: 0,
              right: 0,
              top: screenHeight * 0.7, // ปุ่มลอยกลางจอ
              child: BottomBar(onSaveDraft: _saveDraft, onPublish: _publish),
            ),
          ],
        ),
      ),
    );
  }
}
