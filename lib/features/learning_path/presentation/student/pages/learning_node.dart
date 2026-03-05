import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/learning_node_content.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_quiz.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/node_comments_section.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';

class LearningNodePage extends StatefulWidget {
  final String nodeId;
  final String? pathName;
  final int? totalNodes;
  final int? currentNodeSequence;
  final String userId;

  const LearningNodePage({
    super.key,
    required this.nodeId,
    this.pathName,
    this.totalNodes,
    this.currentNodeSequence,
    required this.userId,
  });

  @override
  State<LearningNodePage> createState() => _LearningNodePageState();
}

class _LearningNodePageState extends State<LearningNodePage> {
  @override
  void initState() {
    super.initState();

    // Start node when page loads
    LogHandler.info('Action: User joined learning node ${widget.nodeId}');
    context.read<LearningPathBloc>().add(
      StartNodeEvent(nodeId: widget.nodeId, userId: widget.userId),
    );

    // Fetch node detail when page loads
    context.read<LearningPathBloc>().add(
      FetchNodeDetail(nodeId: widget.nodeId, userId: widget.userId),
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
              return Center(child: Text('Error: ${state.message}'));
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
                        status: nodeDetail.status,
                        videoUrl: nodeDetail.linkVdo,
                        onTakeQuiz: () async {
                          final bloc = context.read<LearningPathBloc>();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: bloc,
                                child: LearningPathQuizPage(
                                  nodeId: widget.nodeId,
                                  title: nodeDetail.title,
                                  pathName: widget.pathName,
                                  totalNodes: widget.totalNodes,
                                  currentNodeSequence:
                                      widget.currentNodeSequence,
                                  userId: widget.userId,
                                ),
                              ),
                            ),
                          );
                          // Refetch node detail after returning from quiz
                          if (mounted) {
                            bloc.add(FetchNodeDetail(
                              nodeId: widget.nodeId,
                              userId: widget.userId,
                            ));
                          }
                        },
                      ),

                      const SizedBox(height: 32),

                      /// ===== COMMENTS =====
                      CommentsSection(
                        nodeId: widget.nodeId,
                        userId: widget.userId,
                      ),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: Text('Please select a learning path'));
          },
        ),
      ),
    );
  }
}
