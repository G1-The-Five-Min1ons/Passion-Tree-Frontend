import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_core.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_node.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class StudentNodesOverviewPage extends StatefulWidget {
  final LearningPath course;
  final EnrolledLearningPath? enrolledPath;

  const StudentNodesOverviewPage({
    super.key,
    required this.course,
    this.enrolledPath,
  });

  @override
  State<StudentNodesOverviewPage> createState() =>
      _StudentNodesOverviewPageState();
}

class _StudentNodesOverviewPageState extends State<StudentNodesOverviewPage> {
  List<NodeDetail>? _cachedNodes;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _cachedNodes = null;
    _loadUserAndFetchNodes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _loadUserAndFetchNodes() async {
    final storedUserId = await getIt<IAuthRepository>().getUserId();
    if (!mounted) return;
    setState(() => _userId = storedUserId ?? '');
    _fetchNodes(storedUserId ?? '');
  }

  void _fetchNodes(String userId) {
    if (userId.isEmpty) return;
    // Always fetch fresh nodes to ensure up-to-date status
    context.read<LearningPathBloc>().add(
      FetchNodesForPath(pathId: widget.course.id, userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Learning Paths', showBackButton: true),
      body: SafeArea(
        child: BlocBuilder<LearningPathBloc, LearningPathState>(
          builder: (context, state) {
            // Update cached nodes when new nodes loaded
            if (state is NodesLoaded && state.pathId == widget.course.id) {
              _cachedNodes = state.nodes;
            }

            // Show loading only if no cached nodes
            if (state is LearningPathLoading && _cachedNodes == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LearningPathError && _cachedNodes == null) {
              return Center(child: Text('Error: ${state.message}'));
            }

            // Use cached nodes or nodes from state
            final nodes =
                _cachedNodes ?? (state is NodesLoaded ? state.nodes : null);

            if (nodes != null && nodes.isNotEmpty) {
              return Stack(
                children: [
                  /// ===== CORE =====
                  NodesOverviewCore(
                    isEditable: false,
                    nodes: nodes,
                    onNodeTap: (index) {
                      if (index < nodes.length) {
                        final nodeId = nodes[index].nodeId;
                        final currentSequence = nodes[index].sequence;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<LearningPathBloc>(),
                              child: LearningNodePage(
                                nodeId: nodeId,
                                pathName: widget.course.title,
                                totalNodes: nodes.length,
                                currentNodeSequence: currentSequence,
                              ),
                            ),
                          ),
                        ).then((_) {
                          // Refetch nodes when returning from learning node page
                          if (_userId != null && _userId!.isNotEmpty) {
                            _fetchNodes(_userId!);
                          }
                        });
                      }
                    },
                  ),

                  /// ===== HEADER (Dynamic Title + Progress) =====
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderBar(
                          title: widget.course.title,
                          showAddButton: false,
                        ),
                        if (widget.enrolledPath != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                            child: Row(
                              children: [
                                // Status badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  color: widget.enrolledPath!.progressStatus ==
                                          'Completed'
                                      ? AppColors.status
                                      : AppColors.warning,
                                  child: Text(
                                    widget.enrolledPath!.progressStatus,
                                    style: AppTypography.smallBodyMedium
                                        .copyWith(
                                      color: AppColors.background,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Nodes count
                                Text(
                                  '${widget.enrolledPath!.completedNodes} / ${widget.enrolledPath!.modules} nodes',
                                  style: AppTypography.smallBodyMedium
                                      .copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${widget.enrolledPath!.progressPercent.round()}%)',
                                  style: AppTypography.smallBodyMedium
                                      .copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
