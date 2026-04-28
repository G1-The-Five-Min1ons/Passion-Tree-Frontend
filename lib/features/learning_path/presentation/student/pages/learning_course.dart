import 'package:passion_tree_frontend/core/network/log_handler.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/learning_course_content.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_node.dart';

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
  String? _userId;
  EnrolledLearningPath? _enrolledPath;
  LearningPath? _fullCourse;

  @override
  void initState() {
    super.initState();
    _enrolledPath = widget.enrolledPath;
    _loadUserAndFetchNodes();
  }

  String get _title =>
      _enrolledPath?.title ?? _fullCourse?.title ?? widget.course.title;

  String get _description =>
      _enrolledPath?.description ??
      _fullCourse?.description ??
      widget.course.description;

  Future<void> _loadUserAndFetchNodes() async {
    context.read<LearningPathBloc>().add(
      FetchNodesForPath(pathId: widget.course.id),
    );

    final storedUserId = await getIt<IAuthRepository>().getUserId();
    if (!mounted) return;
    setState(() => _userId = storedUserId ?? '');
    if (storedUserId != null && storedUserId.isNotEmpty) {
      context.read<LearningPathBloc>().add(FetchLearningPathOverview());
    }

    if (widget.course.description.isEmpty &&
        (widget.enrolledPath?.description.isEmpty ?? true)) {
      context.read<LearningPathBloc>().add(
        GetLearningPathByIdEvent(pathId: widget.course.id),
      );
    }
  }

  void _handlePreviewNodeTap(int index, List<NodeDetail> nodes) {
    if (index >= nodes.length) return;
    final node = nodes[index];

    LogHandler.info('Action: Preview node tap → nodeId=${node.nodeId}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<LearningPathBloc>(),
          child: LearningNodePage(
            nodeId: node.nodeId,
            pathId: widget.course.id,
            pathName: widget.course.title,
            totalNodes: nodes.length,
            currentNodeSequence: node.sequence,
            userId: _userId ?? '',
            isEnrolled: _enrolledPath != null,
          ),
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      if (_userId?.isNotEmpty == true) {
        context.read<LearningPathBloc>().add(FetchLearningPathOverview());
        context.read<LearningPathBloc>().add(
          FetchNodesForPath(pathId: widget.course.id),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Learning Paths', showBackButton: true),
      body: SafeArea(
        child: BlocListener<LearningPathBloc, LearningPathState>(
          listener: (context, state) {
            if (state is LearningPathDetailLoaded) {
              setState(() {
                _fullCourse = state.learningPath;
              });
            }

            // Update enrolled path state when enrollment succeeds (triggered from node page)
            if (state is PathEnrolled && state.pathId == widget.course.id) {
              setState(() {
                _enrolledPath = state.enrolledPath;
              });
            }

            // Update enrolled path when overview refreshes
            if (state is LearningPathOverviewLoaded) {
              try {
                final updatedPath = state.enrolledPaths.firstWhere(
                  (path) => path.pathId == widget.course.id,
                );
                setState(() => _enrolledPath = updatedPath);
              } catch (_) {
                // Not enrolled yet
              }
            }
          },
          child: BlocBuilder<LearningPathBloc, LearningPathState>(
            builder: (context, state) {
              if (state is NodesLoaded && state.pathId == widget.course.id) {
                _cachedNodes = state.nodes;
              }

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
                        title: _title,
                        description: _description,
                        nodes: nodes,
                        onNodeTap: nodes != null
                            ? (index) => _handlePreviewNodeTap(index, nodes)
                            : null,
                      ),
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
