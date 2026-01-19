
import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_preview_card.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_state.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_bottom.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/learning_node.dart';
import 'package:passion_tree_frontend/core/common_widgets/node_layout/node_canvas.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/ai_node_review_page.dart';  
import 'package:passion_tree_frontend/core/common_widgets/node_layout/positioned_node.dart';

class NodesOverviewPage extends StatefulWidget {
  const NodesOverviewPage({super.key});

  @override
  State<NodesOverviewPage> createState() => _NodesOverviewPageState();
}

class _NodesOverviewPageState extends State<NodesOverviewPage> {
  // TODO: ต่อ backend ทีหลัง
  void _saveDraft() {
    debugPrint('Save draft nodes');
  }

  void _publish() {
    debugPrint('Publish learning path');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Nodes Overview', showBackButton: true),
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable canvas
            Positioned.fill(
              child: NodeCanvas(
                height: 1200,
                children: [
                  PositionedNode(
                    position: const Offset(140, 120),
                    draggable: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AINodeReviewPage(),
                        ),
                      );
                    },
                    child: const LearningNode(state: LearningNodeState.active),
                  ),
                  PositionedNode(
                    position: const Offset(80, 320),
                    child: const LearningNode(state: LearningNodeState.locked),
                  ),
                ],
              ),
            ),

            //  Fixed header
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HeaderBar(),
            ),

            //  Fixed footer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomBar(
                onSaveDraft: _saveDraft,
                onPublish: _publish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
