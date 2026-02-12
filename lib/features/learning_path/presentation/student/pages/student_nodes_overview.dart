import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/node_item.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_canvas.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_bottom.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_asset.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/learning_nodes_mock.dart';
import 'package:passion_tree_frontend/core/common_widgets/popups/confirm_popup.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_core.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_node.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/learning_course_content.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/student_nodes_overview.dart ';

class StudentNodesOverviewPage extends StatelessWidget {
  final Course course;

  const StudentNodesOverviewPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Learning Paths',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            /// ===== CORE =====
            NodesOverviewCore(
              isEditable: false,
              onNodeTap: (index) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LearningNodePage(
                      courseId: course.id,
                      
                    ),
                  ),
                );
              },
            ),

            /// ===== HEADER (Dynamic Title) =====
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: HeaderBar(
                title: course.title, 
                showAddButton: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}