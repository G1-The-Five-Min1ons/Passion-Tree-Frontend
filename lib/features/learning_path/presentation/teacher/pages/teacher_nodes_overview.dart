import 'dart:async';
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
  int? _pendingNodeIndex; // เก็บ index ของ node ที่กำลังสร้างอยู่
  final List<int> _createQueue = []; // คิว index ของ nodes ที่รอสร้างตามลำดับ
  Timer? _draftAutoSaveTimer;
  String? _userId;
  List<NodeDetail>? _cachedNodes; // Cache nodes from backend
  LearningPath? _cachedLearningPath; // Cache learning path details for updating
  bool _pendingPublish = false; // รอ node สร้างเสร็จแล้วค่อย publish
  bool _pendingSaveDraft = false; // รอ node สร้างเสร็จแล้วค่อย save draft
  bool _isAutoSavingDraft = false;
  late String
  _displayTitle; // Title ที่แสดงใน header (อัพเดทจาก backend เมื่อโหลดเสร็จ)

  bool get _isPublished =>
      _cachedLearningPath?.publishStatus.toLowerCase() == 'published';

  bool get _isAiPath => widget.aiNodes != null && widget.aiNodes!.isNotEmpty;

  @override
  void dispose() {
    _draftAutoSaveTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.title;
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
      FetchNodesForPath(pathId: widget.pathId),
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

  /// สร้าง nodes ทีละตัวตามลำดับ (sequential) เพื่อหลีกเลี่ยง droppable transformer
  /// ที่จะ drop events ที่ส่งพร้อมกัน
  void _startSequentialCreate(List<int> indices) {
    _createQueue.clear();
    _createQueue.addAll(indices);
    if (_createQueue.isNotEmpty) {
      _handleCreateNode(_createQueue.removeAt(0));
    }
  }

  void _openEditNodeModal(BuildContext context, {int? index}) {
    if (_isPublished) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot edit nodes. This learning path is already published.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.cancel,
        ),
      );
      return;
    }

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
          isAiPath: _isAiPath,
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

    _scheduleDraftAutoSave();
  }

  bool _hasIncompleteNodesForPublish() {
    return _displayNodes.any(
      (node) {
        final hasTitle =
            node.title.trim().isNotEmpty && node.title.trim() != 'New Node';
        final hasDescription = node.description.trim().isNotEmpty;
        final hasVideoLink = (node.linkVdo ?? '').trim().isNotEmpty;
        final hasQuestions = node.questions.any(
          (question) =>
              question.questionText.trim().isNotEmpty &&
              question.choices
                  .where((choice) => choice.choiceText.trim().isNotEmpty)
                  .length >= 2,
        );

        return !(hasTitle && hasDescription && hasVideoLink && hasQuestions);
      },
    );
  }

  void _scheduleDraftAutoSave() {
    if (_cachedLearningPath == null || _isPublished) {
      return;
    }

    if (_pendingPublish || _pendingSaveDraft) {
      return;
    }

    _draftAutoSaveTimer?.cancel();
    _draftAutoSaveTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted || _cachedLearningPath == null || _isPublished) {
        return;
      }

      _isAutoSavingDraft = true;
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
    });
  }

  void _confirmSaveDraft(BuildContext context) {
    _draftAutoSaveTimer?.cancel();

    if (_cachedLearningPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Loading learning path data...',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.cancel,
        ),
      );
      return;
    }

    // ป้องกันการ save draft เมื่อเป็น published แล้ว
    if (_cachedLearningPath!.publishStatus.toLowerCase() == 'published') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot save as draft. This learning path is already published.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
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
        // ถ้ายังไม่มี nodes ใน backend ให้สร้างทีละตัวตามลำดับ แล้วค่อย save draft
        final uncreatedIndices = [
          for (int i = 0; i < _uiNodes.length; i++)
            if (!_uiNodes[i].isCreated) i,
        ];
        if (uncreatedIndices.isNotEmpty) {
          setState(() => _pendingSaveDraft = true);
          _startSequentialCreate(uncreatedIndices);
          return; // รอ NodeCreated ครบทุกตัวแล้วค่อย dispatch
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
    _draftAutoSaveTimer?.cancel();

    if (_cachedLearningPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Loading learning path data...',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.cancel,
        ),
      );
      return;
    }

    // ถ้า published แล้ว ไม่ต้องทำอะไร
    if (_cachedLearningPath!.publishStatus.toLowerCase() == 'published') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This learning path is already published.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.cancel,
        ),
      );
      return;
    }

    if (_hasIncompleteNodesForPublish()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete every node before publishing: title, description, video, and quiz are required. Materials are optional.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
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
        // ถ้ายังไม่มี nodes ใน backend ให้สร้างทีละตัวตามลำดับ แล้วค่อย publish
        final uncreatedIndices = [
          for (int i = 0; i < _uiNodes.length; i++)
            if (!_uiNodes[i].isCreated) i,
        ];
        if (uncreatedIndices.isNotEmpty) {
          setState(() => _pendingPublish = true);
          _startSequentialCreate(uncreatedIndices);
          return; // รอ NodeCreated ครบทุกตัวแล้วค่อย dispatch
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
            if (state.learningPath.title.isNotEmpty) {
              _displayTitle = state.learningPath.title;
            }
          });
        }

        // Update cached nodes when loaded from backend
        if (state is NodesLoaded && state.pathId == widget.pathId) {
          setState(() {
            _cachedNodes = state.nodes;
            // Rebuild _uiNodes to include ALL backend nodes so that
            // _handleReorder works correctly for both plain path and AI path.
            // Uncreated UI nodes (draft AI nodes not yet saved) are preserved.
            if (state.nodes.isNotEmpty) {
              final newUiNodes = <NodeUiState>[];
              for (final backendNode in state.nodes) {
                final existingIndex = _uiNodes.indexWhere(
                  (n) =>
                      n.realNodeId == backendNode.nodeId ||
                      (n.realNodeId == null &&
                          n.sequence == backendNode.sequence),
                );
                if (existingIndex >= 0) {
                  _uiNodes[existingIndex].title = backendNode.title;
                  _uiNodes[existingIndex].description = backendNode.description;
                  _uiNodes[existingIndex].sequence = backendNode.sequence;
                  _uiNodes[existingIndex].realNodeId = backendNode.nodeId;
                  _uiNodes[existingIndex].isCreated = true;
                  newUiNodes.add(_uiNodes[existingIndex]);
                } else {
                  // Backend node has no matching UI entry (plain path case):
                  // create a new NodeUiState for it so _uiNodes mirrors all nodes.
                  newUiNodes.add(
                    NodeUiState(
                      title: backendNode.title,
                      description: backendNode.description,
                      sequence: backendNode.sequence,
                      realNodeId: backendNode.nodeId,
                      isCreated: true,
                    ),
                  );
                }
              }
              // Preserve uncreated draft nodes that have no backend equivalent yet
              for (final ui in _uiNodes) {
                if (!ui.isCreated &&
                    !newUiNodes.any((n) => n.sequence == ui.sequence)) {
                  newUiNodes.add(ui);
                }
              }
              newUiNodes.sort((a, b) => a.sequence.compareTo(b.sequence));
              _uiNodes = newUiNodes;
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

          // ถ้ายังมี node ที่ต้องสร้างต่อ ให้ทำทีละตัวตามลำดับก่อน finalize
          if (_createQueue.isNotEmpty) {
            _handleCreateNode(_createQueue.removeAt(0));
            return;
          }

          // ถ้ามี pending publish/draft ให้ dispatch UpdateLearningPathEvent หลังสร้างครบทุก node
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

          _scheduleDraftAutoSave();

          // Refetch nodes with a small delay to ensure backend transaction is committed
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _userId != null && _userId!.isNotEmpty) {
              _fetchNodes(_userId!);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Node created successfully',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.status,
            ),
          );
        } else if (state is NodeUpdated) {
          // Node ถูกอัพเดทสำเร็จ
          if (_pendingNodeIndex != null) {
            setState(() {
              _pendingNodeIndex = null;
            });
          }

          _scheduleDraftAutoSave();

          // Refetch nodes with a small delay to ensure backend transaction is committed
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _userId != null && _userId!.isNotEmpty) {
              _fetchNodes(_userId!);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Node updated successfully',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.status,
            ),
          );
        } else if (state is LearningPathUpdated) {
          if (_isAutoSavingDraft) {
            setState(() {
              _isAutoSavingDraft = false;
            });
            return;
          }

          // Learning path updated successfully
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Learning path updated successfully',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.status,
            ),
          );

          // Pop all pages back to the root (teacher_create_tab) in one shot
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (state is LearningPathError) {
          setState(() {
            _pendingNodeIndex = null;
            _isAutoSavingDraft = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
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
                isDraggable: !_isPublished,
                nodes: _displayNodes,
                onNodeTap: _isPublished
                    ? null
                    : (index) {
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
                  title: _displayTitle,
                  showAddButton: !_isPublished,
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
                    isPublished: _isPublished,
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
