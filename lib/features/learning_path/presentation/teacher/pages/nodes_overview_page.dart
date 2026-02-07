
import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/node_item.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_canvas.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_bottom.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_asset.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/learning_nodes_mock.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/edit_node_modal.dart';
import 'package:passion_tree_frontend/core/common_widgets/popups/confirm_popup.dart';


class NodesOverviewPage extends StatefulWidget {
  const NodesOverviewPage({super.key});

  @override
  State<NodesOverviewPage> createState() => _NodesOverviewPageState();
}

class _NodesOverviewPageState extends State<NodesOverviewPage> {
  
  // ===== OPEN EDIT NODE MODAL =====
  void _openEditNodeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EditNodeModal(),
    );
  }

  // ===== CONFIRM POPUPS Save Draft =====
  void _confirmSaveDraft() {
    ConfirmPopup.show(
      context,
      title: 'Save Draft\nConfirmation',
      body: 'Are you sure to save draft?',
      confirmText: 'Confirm',
      onConfirm: () {
        debugPrint('Save draft learning path');
      },
    );
  }

  // ===== CONFIRM POPUPS Publish =====
  void _confirmPublish() {
    ConfirmPopup.show(
      context,
      title: 'Publish\nConfirmation',
      body: 'Are you sure to publish Learning Path?',
      confirmText: 'Confirm',
      onConfirm: () {
        debugPrint('Publish learning path');
      },
    );
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
                  const SizedBox(height: 140), // เว้นที่ให้ header ลอย

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
                              child: Stack(
                                alignment: Alignment.topCenter,
                                clipBehavior: Clip.none,
                                children: [
                                  // ===== NODE (TAP TO OPEN MODAL) =====
                                  NodeItem(
                                    imagePath: NodeAsset.image(node.state),
                                    size: 80,
                                    onTap: () {
                                      _openEditNodeModal();
                                    },
                                  ),

                                  // ===== CURRENT NODE INDICATOR (เก็บไว้ใช้ทีหลัง) =====
                                  /*
                                  if (node.isCurrent)
                                    Positioned(
                                      top: -28,
                                      child: NavigationButton(
                                        direction:
                                            NavigationDirection.down,
                                        onPressed: () {},
                                      ),
                                    ),
                                  */
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 320), // เผื่อปุ่มลอย
                ],
              ),
            ),

            // ===== HEADER (FLOATING + PADDING) =====
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: const HeaderBar(),
              ),
            ),

            // ===== FLOATING BOTTOM BUTTONS =====
            Positioned(
              left: 0,
              right: 0,
              top: screenHeight * 0.65,
              child: BottomBar(
                onSaveDraft: _confirmSaveDraft,
                onPublish: _confirmPublish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
