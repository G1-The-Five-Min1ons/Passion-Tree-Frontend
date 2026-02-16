import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/learning_node_content.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_quiz.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/node_comments_section.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';

class LearningNodePage extends StatefulWidget {
  final String courseId;
  final String? nodeId;

  const LearningNodePage({
    super.key,
    required this.courseId,
    this.nodeId,
  });

  @override
  State<LearningNodePage> createState() => _LearningNodePageState();
}

class _LearningNodePageState extends State<LearningNodePage> {
  @override
  void initState() {
    super.initState();
    // Fetch nodes when page loads
    context.read<LearningPathBloc>().add(
          FetchNodesForPath(pathId: widget.courseId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Learning Paths', showBackButton: true),
      body: SafeArea(
        child: BlocBuilder<LearningPathBloc, LearningPathState>(
          builder: (context, state) {
            if (state is LearningPathLoading || state is LearningPathInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LearningPathError) {
              return Center(
                child: Text('Error: ${state.message}'),
              );
            }

            if (state is NodesLoaded) {
              final nodes = state.nodes;
              
              if (nodes.isEmpty) {
                return const Center(
                  child: Text('No nodes found for this learning path'),
                );
              }

              // Get first node or specific node by nodeId
              final currentNode = widget.nodeId != null
                  ? nodes.firstWhere(
                      (n) => n.nodeId == widget.nodeId,
                      orElse: () => nodes.first,
                    )
                  : nodes.first;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xmargin,
                    right: AppSpacing.xmargin,
                    top: AppSpacing.ymargin,
                    bottom: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ===== NODE CONTENT =====
                      LearningNodeContent(
                        title: currentNode.title,
                        description: currentNode.description,
                        materials: const [], // TODO: Add materials from backend
                        onTakeQuiz: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LearningPathQuizPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      /// ===== COMMENTS =====
                      const NodeCommentsSection(),
                    ],
                  ),
                ),
              );
            }

            return const Center(
              child: Text('Please select a learning path'),
            );
          },
        ),
      ),
    );
  }
}
