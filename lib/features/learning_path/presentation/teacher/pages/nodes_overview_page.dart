
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double canvasHeight = 1200; // TODO: คำนวณจากจำนวน node จริง
    final double availableWidth = screenWidth - (AppSpacing.xmargin * 2);

    return Scaffold(
      appBar: const AppBarWidget(title: 'Nodes Overview', showBackButton: true),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER: ชื่อคอร์ส + ปุ่ม action
            const HeaderBar(),

            // Scrollable canvas only
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xmargin,
                  ),
                  child: SizedBox(
                    height: canvasHeight,
                    child: TreeCanvas(
                      itemCount: 2,
                      canvasWidth: availableWidth,
                      nodeBuilder: (index, pos) {
                        final LearningNodeState state = index == 0
                            ? LearningNodeState.active
                            : LearningNodeState.locked;

                        return Positioned(
                          left: pos.dx - 32,
                          top: pos.dy - 32,
                          child: NodeItem(
                            imagePath: NodeAsset.image(state),
                            size: 64,
                            onTap: state == LearningNodeState.active
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AINodeReviewPage(),
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Fixed bottom bar
            Padding(
              padding: const EdgeInsets.only(
                bottom: 24, // ระยะที่ทำให้ดู "ลอย"
              ),
              child: BottomBar(onSaveDraft: _saveDraft, onPublish: _publish),
            ),

          ],
        ),
      ),
    );
  }
}


