import 'package:passion_tree_frontend/core/network/log_handler.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
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
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class LearningCoursePage extends StatefulWidget {
  final LearningPath course;
  final EnrolledLearningPath? enrolledPath;

  const LearningCoursePage({
    super.key,
    required this.course,
    this.enrolledPath,
  });

  @override
  State<LearningCoursePage> createState() => _LearningCoursePageState();
}

class _LearningCoursePageState extends State<LearningCoursePage> {
  List<NodeDetail>? _cachedNodes;
  bool _isEnrolling = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchNodes();
  }

  Future<void> _loadUserAndFetchNodes() async {
    final storedUserId = await getIt<IAuthRepository>().getUserId();
    if (!mounted) return;
    setState(() => _userId = storedUserId ?? '');
    if (storedUserId != null && storedUserId.isNotEmpty) {
      context.read<LearningPathBloc>().add(
        FetchNodesForPath(pathId: widget.course.id, userId: storedUserId),
      );
    }
  }

  void _handleStartJourney(BuildContext context) {
    final userId = _userId ?? '';
    if (userId.isEmpty) return;

    // If not enrolled yet, enroll first
    if (widget.enrolledPath == null) {
      setState(() => _isEnrolling = true);

      context.read<LearningPathBloc>().add(
        EnrollPathEvent(pathId: widget.course.id, userId: userId),
      );
    } else {
      // Already enrolled, navigate directly
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<LearningPathBloc>(),
            child: StudentNodesOverviewPage(
              course: widget.course,
              enrolledPath: widget.enrolledPath,
            ),
          ),
        ),
      ).then((_) {
        // Refetch overview data when returning (in case user completes a course)
        context.read<LearningPathBloc>().add(
          FetchLearningPathOverview(userId: userId),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Learning Paths', showBackButton: true),
      body: SafeArea(
        child: BlocListener<LearningPathBloc, LearningPathState>(
          listener: (context, state) {
            // Handle enrollment success
            if (state is PathEnrolled &&
                state.pathId == widget.course.id &&
                _isEnrolling) {
              setState(() => _isEnrolling = false);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<LearningPathBloc>(),
                    child: StudentNodesOverviewPage(
                      course: widget.course,
                      enrolledPath: widget.enrolledPath,
                    ),
                  ),
                ),
              ).then((_) {
                // Refetch overview data when returning from nodes overview
                final userId = _userId ?? '';
                if (userId.isNotEmpty) {
                  context.read<LearningPathBloc>().add(
                    FetchLearningPathOverview(userId: userId),
                  );
                }
              });
            }

            // Handle enrollment error
            if (state is LearningPathError && _isEnrolling) {
              LogHandler.error('[UI] Enrollment failed: ${state.message}');
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
                        title:
                            widget.enrolledPath?.title ?? widget.course.title,
                        description:
                            widget.enrolledPath?.description ??
                            widget.course.description,
                        isEnrolled: widget.enrolledPath != null,
                        nodes: nodes,
                        onStartJourney: () => _handleStartJourney(context),
                      ),

                      if (nodes != null) ...[
                        const SizedBox(height: 32),
                        CommentsSection(
                          pathId: widget.course.id,
                          userId: _userId ?? '',
                        ),
                      ],
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
