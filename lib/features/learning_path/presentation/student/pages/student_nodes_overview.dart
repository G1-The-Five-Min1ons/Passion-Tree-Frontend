
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_core.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_node.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';

class StudentNodesOverviewPage extends StatefulWidget {
  final LearningPath course;

  const StudentNodesOverviewPage({
    super.key,
    required this.course,
  });

  @override
  State<StudentNodesOverviewPage> createState() => _StudentNodesOverviewPageState();
}

class _StudentNodesOverviewPageState extends State<StudentNodesOverviewPage> {
  List<NodeDetail>? _cachedNodes;

  @override
  void initState() {
    super.initState();
    // TODO: Get userId from authentication service
    const userId = '3f9b2c6d-8288-4647-8d33-33d96e1a82b3'; // Hardcoded for testing
    
    // Always fetch fresh nodes to ensure up-to-date status
    context.read<LearningPathBloc>().add(
      FetchNodesForPath(
        pathId: widget.course.id,
        userId: userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Learning Paths',
        showBackButton: true,
      ),
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
            final nodes = _cachedNodes ?? 
                (state is NodesLoaded ? state.nodes : null);

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
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LearningNodePage(
                              nodeId: nodeId,
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  /// ===== HEADER (Dynamic Title) =====
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: HeaderBar(
                      title: widget.course.title,
                      showAddButton: false,
                    ),
                  ),
                ],
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
