
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
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';

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
  List<NodeDetail>? _cachedNodes;
  bool _isEnrolling = false;

  @override
  void initState() {
    super.initState();
    
    debugPrint('[UI] LearningCoursePage - Fetching nodes for preview');
    const userId = 'a33282ca-e6f1-4fbf-9f51-fab7ffba3bfc'; // TODO: Get from auth
    
    context.read<LearningPathBloc>().add(
      FetchNodesForPath(
        pathId: widget.course.id,
        userId: userId,
      ),
    );
  }

  void _handleStartJourney(BuildContext context) {
    const userId = 'a33282ca-e6f1-4fbf-9f51-fab7ffba3bfc'; // TODO: Get from auth
    
    // If not enrolled yet, enroll first
    if (widget.enrolledPath == null) {
      debugPrint('[UI] ========== START ENROLLMENT ==========');
      debugPrint('[UI] Not enrolled yet, enrolling user in path...');
      debugPrint('[UI] Path ID: ${widget.course.id}');
      debugPrint('[UI] Path Title: ${widget.course.title}');
      debugPrint('[UI] User ID: $userId');
      setState(() => _isEnrolling = true);
      
      context.read<LearningPathBloc>().add(
        EnrollPathEvent(
          pathId: widget.course.id,
          userId: userId,
        ),
      );
      debugPrint('[UI] EnrollPathEvent dispatched');
    } else {
      // Already enrolled, navigate directly
      debugPrint('[UI] Already enrolled, navigating to nodes overview');
      debugPrint('[UI] Enrolled Path ID: ${widget.enrolledPath!.pathId}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<LearningPathBloc>(),
            child: StudentNodesOverviewPage(course: widget.course),
          ),
        ),
      ).then((_) {
        // Refetch overview data when returning (in case user completes a course)
        debugPrint('[UI] Returned from nodes overview, refetching overview data...');
        context.read<LearningPathBloc>().add(
          FetchLearningPathOverview(userId: userId),
        );
      });
    }
  }

  @override  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Learning Paths', showBackButton: true),
      body: SafeArea(
        child: BlocListener<LearningPathBloc, LearningPathState>(
          listener: (context, state) {
            debugPrint('[UI] BlocListener - State changed: ${state.runtimeType}');
            debugPrint('[UI] Current _isEnrolling: $_isEnrolling');
            
            // Handle enrollment success
            if (state is PathEnrolled) {
              debugPrint('[UI] State is PathEnrolled!');
              debugPrint('[UI] state.pathId: ${state.pathId}');
              debugPrint('[UI] widget.course.id: ${widget.course.id}');
              debugPrint('[UI] Matches: ${state.pathId == widget.course.id}');
            }
            
            if (state is PathEnrolled && 
                state.pathId == widget.course.id && 
                _isEnrolling) {
              debugPrint('[UI] ========== ENROLLMENT SUCCESS ==========');
              debugPrint('[UI] Enrollment successful!');
              debugPrint('[UI] Enrolled Path ID: ${state.pathId}');
              debugPrint('[UI] User ID: ${state.userId}');
              debugPrint('[UI] Navigating to nodes overview...');
              setState(() => _isEnrolling = false);
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<LearningPathBloc>(),
                    child: StudentNodesOverviewPage(course: widget.course),
                  ),
                ),
              ).then((_) {
                // Refetch overview data when returning from nodes overview
                debugPrint('[UI] Returned from nodes overview, refetching overview data...');
                const userId = 'a33282ca-e6f1-4fbf-9f51-fab7ffba3bfc';
                context.read<LearningPathBloc>().add(
                  FetchLearningPathOverview(userId: userId),
                );
              });
              debugPrint('[UI] Navigation completed');
            }
            
            // Handle enrollment error
            if (state is LearningPathError && _isEnrolling) {
              debugPrint('[UI] ========== ENROLLMENT FAILED ==========');
              debugPrint('[UI] Enrollment failed!');
              debugPrint('[UI] Error: ${state.message}');
              debugPrint('[UI] Path ID: ${widget.course.id}');
              debugPrint('[UI] _isEnrolling: $_isEnrolling');
              setState(() => _isEnrolling = false);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to enroll: ${state.message}')),
              );
            }
          },
          child: BlocBuilder<LearningPathBloc, LearningPathState>(
            builder: (context, state) {
              // Update cached nodes when NodesLoaded state is received
              if (state is NodesLoaded && state.pathId == widget.course.id) {
                _cachedNodes = state.nodes;
              }
              
              // Use cached nodes to prevent loading spinner when returning from node detail page
              final nodes = _cachedNodes;

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
                      onStartJourney: () => _handleStartJourney(context),
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
      ),
    );
  }
}
