
import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_core.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_node.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';

class StudentNodesOverviewPage extends StatelessWidget {
  final LearningPath course;

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
