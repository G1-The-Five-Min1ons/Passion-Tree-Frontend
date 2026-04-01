import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_bottom.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/edit_node_modal.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_core.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/popups/teacher/confirm_popup.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/generated_node.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

// UI State class สำหรับจัดการ node ใน UI
class NodeUiState {
  String title;
  String description;
  int sequence;
  String? realNodeId;
  bool isCreated;

  NodeUiState({
    required this.title,
    required this.description,
    required this.sequence,
    this.realNodeId,
    this.isCreated = false,
  });
}

class TeacherNodesOverviewPage extends StatefulWidget {
  final String title;
  final List<GeneratedNode>? aiNodes;
  final String pathId;

  const TeacherNodesOverviewPage({
    super.key,
    required this.title,
    this.aiNodes,
    required this.pathId,
  });

  @override
  State<TeacherNodesOverviewPage> createState() =>
      _TeacherNodesOverviewPageState();
}

class _TeacherNodesOverviewPageState extends State<TeacherNodesOverviewPage> {
  late List<NodeUiState> _uiNodes;
  int? _pendingNodeIndex; // เก็บ index ของ node ที่รอ response จาก BLoC
  String? _userId;
  List<NodeDetail>? _cachedNodes; // Cache nodes from backend
  LearningPath? _cachedLearningPath; // Cache learning path details for updating
  bool _pendingPublish = false; // รอ node สร้างเสร็จแล้วค่อย publish
  bool _pendingSaveDraft = false; // รอ node สร้างเสร็จแล้วค่อย save draft

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchNodes();

    // ถ้ามี AI nodes ให้ใช้ ถ้าไม่มีให้สร้าง default node เปล่าๆ
    if (widget.aiNodes != null && widget.aiNodes!.isNotEmpty) {
      _uiNodes = widget.aiNodes!.map((aiNode) {
        return NodeUiState(
          title: aiNode.title,
          description: "",
          sequence: aiNode.sequence,
          isCreated: false,
        );
      }).toList();
    } else {
      // Create Plain Path: สร้าง node เปล่าๆ 1 node (ถ้ายังไม่มี nodes จาก backend)
      _uiNodes = [
        NodeUiState(
          title: 'New Node',
          description: '',
          sequence: 1,
          isCreated: false,
        ),
      ];
    }
  }

  Future<void> _loadUserAndFetchNodes() async {
    final storedUserId = await getIt<IAuthRepository>().getUserId();
    if (!mounted) return;

    setState(() => _userId = storedUserId ?? '');
    _fetchNodes(storedUserId ?? '');
    _fetchLearningPathDetail();
  }

  void _fetchNodes(String userId) {
    if (userId.isEmpty) return;
    // Fetch existing nodes from backend
    context.read<LearningPathBloc>().add(
      FetchNodesForPath(pathId: widget.pathId, userId: userId),
    );
  }

  void _fetchLearningPathDetail() {
    // Fetch learning path details for updating publish status
    context.read<LearningPathBloc>().add(
      GetLearningPathByIdEvent(pathId: widget.pathId),
    );
  }

  void _handleCreateNode(int index) {
    final node = _uiNodes[index];

    setState(() {
      _pendingNodeIndex = index;
    });

    context.read<LearningPathBloc>().add(
      CreateNodeEvent(
        title: node.title,
        description: node.description,
        pathId: widget.pathId,
        sequence: node.sequence.toString(),
        linkvdo: '',
        materials: null, // Materials จะถูกเพิ่มผ่าน EditNodeModal
      ),
    );
  }

  void _openEditNodeModal(BuildContext context, {int? index}) {
    String nodeId;
    bool isNewNode;
    String? sequence;
    NodeDetail? initialNode;

    if (index != null && index < _displayNodes.length) {
      final displayNode = _displayNodes[index];
      final isBackendNode =
          _cachedNodes?.any((n) => n.nodeId == displayNode.nodeId) ?? false;

      if (isBackendNode) {
        // แก้ไข node ที่มีอยู่แล้วจาก backend
        nodeId = displayNode.nodeId;
        isNewNode = false;
        sequence = null;
        initialNode = displayNode;
      } else {
        // AI node ที่ยังไม่ถูกสร้างใน backend
        nodeId = 'new_node_${DateTime.now().millisecondsSinceEpoch}';
        isNewNode = true;
        sequence = displayNode.sequence.toString();
        initialNode = displayNode;
      }
    } else {
      // สร้าง node ใหม่
      nodeId = 'new_node_${DateTime.now().millisecondsSinceEpoch}';
      isNewNode = true;
      final currentNodeCount = _cachedNodes?.length ?? _uiNodes.length;
      sequence = (currentNodeCount + 1).toString();
      initialNode = null;
    }

    final bloc = context.read<LearningPathBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: EditNodeModal(
          nodeId: nodeId,
          isNewNode: isNewNode,
          pathId: widget.pathId,
          sequence: sequence,
          initialNode: initialNode, // ส่งข้อมูลเดิมไปยัง modal
        ),
      ),
    );
  }

  void _handleReorder(int fromIndex, int toIndex) {
    setState(() {
      final item = _uiNodes.removeAt(fromIndex);
      _uiNodes.insert(toIndex, item);
      // Update sequences to reflect new order
      for (int i = 0; i < _uiNodes.length; i++) {
        _uiNodes[i].sequence = i + 1;
      }
      // Also reorder cached nodes to keep _displayNodes in sync
      if (_cachedNodes != null && fromIndex < _cachedNodes!.length) {
        final cachedItem = _cachedNodes!.removeAt(fromIndex);
        if (toIndex <= _cachedNodes!.length) {
          _cachedNodes!.insert(toIndex, cachedItem);
        } else {
          _cachedNodes!.add(cachedItem);
        }
      }
    });

    // Sync new order to backend using realNodeIds only (skip draft nodes)
    final orderedNodeIds = _uiNodes
        .where((n) => n.realNodeId != null)
        .map((n) => n.realNodeId!)
        .toList();

    if (orderedNodeIds.isNotEmpty) {
      context.read<LearningPathBloc>().add(
        ReorderNodesEvent(pathId: widget.pathId, nodeIds: orderedNodeIds),
      );
    }
  }

  void _confirmSaveDraft(BuildContext context) {
    if (_cachedLearningPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading learning path data...', style: TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.cancel),
      );
      return;
    }

    // ป้องกันการ save draft เมื่อเป็น published แล้ว
    if (_cachedLearningPath!.publishStatus.toLowerCase() == 'published') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot save as draft. This learning path is already published.', style: TextStyle(color: AppColors.textPrimary)),
          backgroundColor: AppColors.cancel,
        ),
      );
      return;
    }

    ConfirmPopup.show(
      context,
      title: 'Save Draft\n Confirmation',
      body: 'Are you sure to save draft',
      confirmText: 'Save',
      onConfirm: () {
        // ถ้ายังไม่มี nodes ใน backend ให้สร้างก่อน แล้วค่อย save draft
        if (_cachedNodes == null || _cachedNodes!.isEmpty) {
          final hasUncreated = _uiNodes.any((n) => !n.isCreated);
          if (hasUncreated) {
            setState(() => _pendingSaveDraft = true);
            for (int i = 0; i < _uiNodes.length; i++) {
              if (!_uiNodes[i].isCreated) {
                _handleCreateNode(i);
              }
            }
            return; // รอ NodeCreated แล้วค่อย dispatch
          }
        }

        context.read<LearningPathBloc>().add(
          UpdateLearningPathEvent(
            pathId: widget.pathId,
            title: _cachedLearningPath!.title,
            objective: _cachedLearningPath!.objective,
            description: _cachedLearningPath!.description,
            coverImgUrl: _cachedLearningPath!.coverImageUrl,
            publishStatus: 'draft',
          ),
        );
      },
    );
  }

  void _confirmPublish(BuildContext context) {
    if (_cachedLearningPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading learning path data...', style: TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.cancel),
      );
      return;
    }

    // ถ้า published แล้ว ไม่ต้องทำอะไร
    if (_cachedLearningPath!.publishStatus.toLowerCase() == 'published') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This learning path is already published.', style: TextStyle(color: AppColors.textPrimary)),
          backgroundColor: AppColors.cancel,
        ),
      );
      return;
    }

    ConfirmPopup.show(
      context,
      title: 'Publish\n Confirmation',
      body: 'Are you sure to publish Learning Path',
      confirmText: 'Publish',
      onConfirm: () {
        // ถ้ายังไม่มี nodes ใน backend ให้สร้างก่อน แล้วค่อย publish
        if (_cachedNodes == null || _cachedNodes!.isEmpty) {
          final hasUncreated = _uiNodes.any((n) => !n.isCreated);
          if (hasUncreated) {
            setState(() => _pendingPublish = true);
            for (int i = 0; i < _uiNodes.length; i++) {
              if (!_uiNodes[i].isCreated) {
                _handleCreateNode(i);
              }
            }
            return; // รอ NodeCreated แล้วค่อย dispatch
          }
        }

        context.read<LearningPathBloc>().add(
          UpdateLearningPathEvent(
            pathId: widget.pathId,
            title: _cachedLearningPath!.title,
            objective: _cachedLearningPath!.objective,
            description: _cachedLearningPath!.description,
            coverImgUrl: _cachedLearningPath!.coverImageUrl,
            publishStatus: 'published',
          ),
        );
      },
    );
  }

  List<NodeDetail> _buildFallbackNodesFromUiState() {
    return _uiNodes
        .map(
          (uiNode) => NodeDetail(
            nodeId: uiNode.realNodeId ?? 'draft_node_${uiNode.sequence}',
            title: uiNode.title,
            description: uiNode.description,
            sequence: uiNode.sequence,
            pathId: widget.pathId,
            materials: const [],
            questions: const [],
            status: 'locked',
            complete: 'false',
            linkVdo: null,
          ),
        )
        .toList();
  }

  List<NodeDetail> get _displayNodes {
    final backendNodes = _cachedNodes;
    final uncreatedNodes = _uiNodes.where((n) => !n.isCreated).toList();

    if (backendNodes != null && backendNodes.isNotEmpty) {
      if (uncreatedNodes.isEmpty) return backendNodes;

      // Merge backend nodes + uncreated AI nodes, sorted by sequence
      final merged = [
        ...backendNodes,
        ...uncreatedNodes.map(
          (uiNode) => NodeDetail(
            nodeId: 'draft_node_${uiNode.sequence}',
            title: uiNode.title,
            description: uiNode.description,
            sequence: uiNode.sequence,
            pathId: widget.pathId,
            materials: const [],
            questions: const [],
            status: 'locked',
            complete: 'false',
            linkVdo: null,
          ),
        ),
      ];
      merged.sort((a, b) => a.sequence.compareTo(b.sequence));
      return merged;
    }
    return _buildFallbackNodesFromUiState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<LearningPathBloc, LearningPathState>(
      listener: (context, state) {
        // Update cached learning path when loaded
        if (state is LearningPathDetailLoaded) {
          setState(() {
            _cachedLearningPath = state.learningPath;
          });
        }

        // Update cached nodes when loaded from backend
        if (state is NodesLoaded && state.pathId == widget.pathId) {
          setState(() {
            _cachedNodes = state.nodes;
            // Only update _uiNodes that match backend nodes (by realNodeId or sequence)
            // Keep uncreated AI nodes intact so they don't disappear
            if (state.nodes.isNotEmpty) {
              for (final backendNode in state.nodes) {
                final uiIndex = _uiNodes.indexWhere(
                  (n) =>
                      n.realNodeId == backendNode.nodeId ||
                      (n.realNodeId == null &&
                          n.sequence == backendNode.sequence),
                );
                if (uiIndex >= 0) {
                  _uiNodes[uiIndex].title = backendNode.title;
                  _uiNodes[uiIndex].description = backendNode.description;
                  _uiNodes[uiIndex].sequence = backendNode.sequence;
                  _uiNodes[uiIndex].realNodeId = backendNode.nodeId;
                  _uiNodes[uiIndex].isCreated = true;
                }
              }
            }
          });
        }

        if (state is NodeDeleted) {
          // Refetch nodes after deletion
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _userId != null && _userId!.isNotEmpty) {
              _fetchNodes(_userId!);
            }
          });
        }

        if (state is NodeCreated) {
          // Node ถูกสร้างสำเร็จ อัพเดท UI state
          if (_pendingNodeIndex != null) {
            setState(() {
              _uiNodes[_pendingNodeIndex!].realNodeId = state.nodeId;
              _uiNodes[_pendingNodeIndex!].isCreated = true;
              _pendingNodeIndex = null;
            });
          }

          // ถ้ามี pending publish/draft ให้ dispatch UpdateLearningPathEvent ทันที
          if (_pendingPublish || _pendingSaveDraft) {
            final status = _pendingPublish ? 'published' : 'draft';
            setState(() {
              _pendingPublish = false;
              _pendingSaveDraft = false;
            });
            context.read<LearningPathBloc>().add(
              UpdateLearningPathEvent(
                pathId: widget.pathId,
                title: _cachedLearningPath!.title,
                objective: _cachedLearningPath!.objective,
                description: _cachedLearningPath!.description,
                coverImgUrl: _cachedLearningPath!.coverImageUrl,
                publishStatus: status,
              ),
            );
            return;
          }

          // Refetch nodes with a small delay to ensure backend transaction is committed
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _userId != null && _userId!.isNotEmpty) {
              _fetchNodes(_userId!);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Node created successfully', style: TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.status),
          );
        } else if (state is NodeUpdated) {
          // Node ถูกอัพเดทสำเร็จ
          if (_pendingNodeIndex != null) {
            setState(() {
              _pendingNodeIndex = null;
            });
          }

          // Refetch nodes with a small delay to ensure backend transaction is committed
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _userId != null && _userId!.isNotEmpty) {
              _fetchNodes(_userId!);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Node updated successfully', style: TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.status),
          );
        } else if (state is LearningPathUpdated) {
          // Learning path updated successfully
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Learning path updated successfully', style: TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.status),
          );

          // Pop all pages back to the root (teacher_create_tab) in one shot
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (state is LearningPathError) {
          setState(() {
            _pendingNodeIndex = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}', style: const TextStyle(color: AppColors.textPrimary)),
              backgroundColor: AppColors.cancel,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: const AppBarWidget(
          title: 'Nodes Overview',
          showBackButton: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              /// ===== CORE =====
              NodesOverviewCore(
                isEditable: true,
                isDraggable: _cachedLearningPath?.publishStatus.toLowerCase() != 'published',
                nodes: _displayNodes,
                onNodeTap: (index) {
                  _openEditNodeModal(context, index: index);
                },
                onReorder: _handleReorder,
              ),

              /// ===== HEADER =====
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: HeaderBar(
                  title: widget.title,
                  showAddButton:
                      _cachedLearningPath?.publishStatus.toLowerCase() !=
                      'published',
                  onPressed: () => _openEditNodeModal(context),
                ),
              ),

              /// ===== FLOATING BOTTOM =====
              Positioned(
                top: screenHeight * 0.65,
                left: 0,
                right: 0,
                child: Builder(
                  builder: (bottomContext) => BottomBar(
                    onSaveDraft: () => _confirmSaveDraft(bottomContext),
                    onPublish: () => _confirmPublish(bottomContext),
                    isPublished:
                        _cachedLearningPath?.publishStatus.toLowerCase() ==
                        'published',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
