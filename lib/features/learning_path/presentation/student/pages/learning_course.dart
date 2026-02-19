
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/learning_course_content.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/student_nodes_overview.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/node_comments_section.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';

class LearningCoursePage extends StatefulWidget {
  final LearningPath course;
  final EnrolledLearningPath? enrolledPath;

  const LearningCoursePage({
    super.key,
    required this.course,
    this.enrolledPath,
  });

  @override  State<LearningCoursePage> createState() => _LearningCoursePageState();
}

class _LearningCoursePageState extends State<LearningCoursePage> {
  @override
  void initState() {
    super.initState();
    
    debugPrint('[UI] LearningCoursePage - Fetching nodes for preview');
    const userId = 'a4bdfa58-e41e-4344-aa9e-d35f3dcd53c6'; // TODO: Get from auth
    
    context.read<LearningPathBloc>().add(
      FetchNodesForPath(
        pathId: widget.course.id,
        userId: userId,
      ),
    );
  }

  @override  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Learning Paths', showBackButton: true),
      body: SafeArea(
        child: BlocBuilder<LearningPathBloc, LearningPathState>(
          builder: (context, state) {
            final nodes = state is NodesLoaded && state.pathId == widget.course.id
                ? state.nodes
                : null;

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
                    /// ===== COURSE CONTENT =====
                    LearningCourseContent(
                      title: widget.enrolledPath?.title ?? widget.course.title,
                      description: widget.enrolledPath?.description ?? widget.course.description,
                      isEnrolled: widget.enrolledPath != null,
                      nodes: nodes,
                      onStartJourney: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<LearningPathBloc>(),
                              child: StudentNodesOverviewPage(course: widget.course),
                            ),
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
          },
        ),
      ),
    );
  }
}
