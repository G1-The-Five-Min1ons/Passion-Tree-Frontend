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
  final String nodeId;

  const LearningNodePage({
    super.key,
    required this.nodeId,
  });

  @override
  State<LearningNodePage> createState() => _LearningNodePageState();
}

class _LearningNodePageState extends State<LearningNodePage> {
  @override
  void initState() {
    super.initState();
    // Fetch node detail when page loads
    context.read<LearningPathBloc>().add(
          FetchNodeDetail(nodeId: widget.nodeId),
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

            if (state is NodeDetailLoaded) {
              final nodeDetail = state.nodeDetail;

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
                        title: nodeDetail.title,
                        description: nodeDetail.description,
                        materials: nodeDetail.materials,
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
