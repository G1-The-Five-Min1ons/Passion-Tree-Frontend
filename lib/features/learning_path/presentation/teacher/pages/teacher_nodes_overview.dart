
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
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_core.dart';

class TeacherNodesOverviewPage extends StatelessWidget {
  final String title;

  const TeacherNodesOverviewPage({super.key, required this.title});

  void _openEditNodeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EditNodeModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const AppBarWidget(title: 'Nodes Overview', showBackButton: true),
      body: SafeArea(
        child: Stack(
          children: [
            /// ===== CORE =====
            NodesOverviewCore(
              isEditable: true,
              onNodeTap: (index) {
                _openEditNodeModal(context);
              },
            ),

            /// ===== HEADER =====
            Positioned(
              top: 16,
              left: 0,
              right: 0,
                child: HeaderBar(
                  title: title,
                  showAddButton: true,
                  onPressed: () => _openEditNodeModal(context),
                ),
            ),

            /// ===== FLOATING BOTTOM =====
            Positioned(
              top: screenHeight * 0.65,
              left: 0,
              right: 0,
              child: BottomBar(onSaveDraft: () {}, onPublish: () {}),
            ),
          ],
        ),
      ),
    );
  }
}
